## fused_sgl.R
## ----------------------------------------------------------------------------
## Fused Sparse Group Lasso, built on top of `sparsegl`.
##
## Objective (matches sparsegl's normalisation exactly when lambda_fus = 0):
##
##   (1/(2n)) * || y - X b ||^2
##     + (1 - alpha) * lambda * sum_g  pf_group_g  * || b^(g) ||_2
##     +       alpha * lambda * sum_j  pf_sparse_j * | b_j |
##     +     lambda_fus       * sum_m  || delta_{m+1} - delta_m ||_2
##
## where
##   * pf_group   defaults to sqrt(bs)         (same as sparsegl)
##   * pf_sparse  is rescaled internally so that sum(pf_sparse) = nvars
##                (same as sparsegl)
##   * delta_m is the coefficient block of the m-th "fusion group" (e.g. age),
##     and the fusion penalty acts on the L2 norm (NOT squared) of consecutive
##     differences -- a group-lasso penalty on first differences.
##
## Solver:
##   * lambda_fus == 0  ->  delegate directly to sparsegl (exact match).
##   * lambda_fus  > 0  ->  ADMM with split z = D b. The b-update
##
##         min_b (1/(2n))||y - Xb||^2 + (rho/2)||Db - v||^2 + SGL_penalty(b)
##
##     is solved by a small block coordinate descent that mimics sparsegl's
##     Fortran update_step exactly: per-group prox-gradient with
##         grad_g = -(1/n) X_g' r + rho D_g' q       (r = y-Xb, q = Db-v)
##         step   = 1 / L_g, L_g = max-eig of (X_g'X_g)/n + rho D_g'D_g
##         s      = b_g - step * grad_g
##         s      <- soft_thresh(s, step * alpha * lambda * pf_sparse_g)
##         b_g    <- s * max(0, 1 - step*(1-alpha)*lambda*pf_group_g / ||s||)
##     using pf_group = sqrt(|g|) and pf_sparse = 1 (the sparsegl defaults,
##     and pf_sparse already sums to nvars so no rescaling is needed).
##
##     We do NOT call sparsegl as the inner solver: feeding it an augmented
##     (X; sqrt(n*rho)*D) design crashes RSpectra::svds inside calc_gamma()
##     because the difference block is highly singular ("TridiagEigen: eigen
##     decomposition failed"). Solving the b-update directly avoids that
##     entirely and warm-starts naturally between ADMM iterations.
## ----------------------------------------------------------------------------

suppressPackageStartupMessages({
  if (!requireNamespace("sparsegl", quietly = TRUE)) {
    stop("This file requires the `sparsegl` package.")
  }
})

# ---- helpers ----------------------------------------------------------------

.group_columns <- function(group) {
  group <- as.integer(group)
  bs <- as.integer(table(group))
  cum <- cumsum(c(0L, bs))
  list(
    bs = bs,
    bn = length(bs),
    col_of = function(g) seq.int(cum[g] + 1L, cum[g] + bs[g])
  )
}

.build_diff_matrix <- function(p, group, fuse_groups) {
  gi <- .group_columns(group)
  K <- gi$bs[fuse_groups[1]]
  if (any(gi$bs[fuse_groups] != K)) {
    stop("All `fuse_groups` must have the same group size.")
  }
  M <- length(fuse_groups)
  D <- matrix(0, nrow = (M - 1L) * K, ncol = p)
  for (m in seq_len(M - 1L)) {
    rows <- ((m - 1L) * K + 1L):(m * K)
    cm   <- gi$col_of(fuse_groups[m])
    cm1  <- gi$col_of(fuse_groups[m + 1L])
    D[cbind(rows, cm)]  <- -1
    D[cbind(rows, cm1)] <-  1
  }
  list(D = D, K = K, M = M)
}

.detect_change_points <- function(beta, group, fuse_groups, tol = 1e-4) {
  if (is.null(fuse_groups) || length(fuse_groups) < 2L) return(integer(0))
  gi <- .group_columns(group)
  cps <- integer(0)
  for (m in seq_len(length(fuse_groups) - 1L)) {
    d <- beta[gi$col_of(fuse_groups[m + 1L])] -
         beta[gi$col_of(fuse_groups[m])]
    if (sqrt(sum(d * d)) > tol) cps <- c(cps, m)
  }
  cps
}

.bic_from_coef <- function(y, fitted, df, n) {
  rss <- sum((y - fitted)^2)
  mse <- rss / n
  list(bic = log(mse) + log(n) * df / n, mse = mse, rss = rss)
}

# Pure-SGL path + BIC selection (matches user's reference exactly when called
# with the same arguments).
.sgl_bic <- function(X, y, group, alpha, intercept, lambda = NULL, ...) {
  fit <- sparsegl::sparsegl(
    x = X, y = y, group = group, asparse = alpha,
    intercept = intercept, ...
  )
  er <- sparsegl::estimate_risk(fit, X, type = "BIC", approx_df = TRUE)
  if (is.null(lambda)) {
    idx <- which.min(er$BIC)
  } else {
    idx <- which.min(abs(fit$lambda - lambda))
  }
  lam <- fit$lambda[idx]
  co <- as.numeric(stats::coef(fit, s = lam))
  if (length(co) == ncol(X) + 1L) {
    b0 <- co[1]; beta <- co[-1]
  } else {
    b0 <- 0;     beta <- co
  }
  list(beta = beta, b0 = b0, lambda = lam, bic = er$BIC[idx],
       df = er$df[idx], fit = fit, er = er)
}

# ---- main entry -------------------------------------------------------------

#' Fused sparse group lasso.
#'
#' @param X         numeric matrix (n x p).
#' @param y         numeric vector length n.
#' @param group     integer vector length p, sorted, consecutively numbered.
#' @param alpha     sparse-group mix in [0, 1] (passed as `asparse`).
#' @param lambda    optional single SGL lambda. If NULL, picked by BIC over the
#'                  default sparsegl path (using the unfused fit when
#'                  lambda_fus > 0, which is a sensible warm anchor).
#' @param lambda_fus fusion penalty strength.
#' @param fuse_groups vector of group indices, in temporal order, to which
#'                  fusion applies (consecutive pairs). Required if
#'                  lambda_fus > 0.
#' @param intercept logical (default FALSE). Only FALSE is supported when
#'                  lambda_fus > 0; pre-center y yourself if needed.
#' @param rho       ADMM penalty parameter.
#' @param max_iter  ADMM max outer iterations.
#' @param tol       ADMM stopping tolerance (on primal/dual residuals).
#' @param cp_tol    threshold for declaring a change point.
#' @param verbose   print ADMM progress.
#'
#' @return list with components: beta, b0, lambda, lambda_fus, alpha, bic,
#'   mse, df, iters, converged, change_points.
fused_sgl <- function(X, y, group,
                      alpha       = 0.85,
                      lambda      = NULL,
                      lambda_fus  = 0,
                      fuse_groups = NULL,
                      intercept   = FALSE,
                      rho         = 1,
                      max_iter    = 500L,
                      tol         = 1e-6,
                      cp_tol      = 1e-4,
                      verbose     = FALSE,
                      ...) {
  n <- nrow(X); p <- ncol(X)
  group <- as.integer(group)

  ## ------ short-circuit: lambda_fus == 0  ------------------------------------
  if (lambda_fus <= 0) {
    out <- .sgl_bic(X, y, group, alpha, intercept, lambda = lambda, ...)
    fitted <- as.numeric(X %*% out$beta) + out$b0
    info <- .bic_from_coef(y, fitted, out$df, n)
    return(list(
      beta          = out$beta,
      b0            = out$b0,
      lambda        = out$lambda,
      lambda_fus    = 0,
      alpha         = alpha,
      bic           = out$bic,        # sparsegl-style BIC (matches reference)
      mse           = info$mse,
      df            = out$df,
      iters         = 0L,
      converged     = TRUE,
      change_points = .detect_change_points(out$beta, group, fuse_groups, cp_tol)
    ))
  }

  ## ------ general case: ADMM -------------------------------------------------
  if (intercept) {
    stop("`intercept = TRUE` is not supported when lambda_fus > 0; ",
         "center y yourself.")
  }
  if (is.null(fuse_groups) || length(fuse_groups) < 2L) {
    stop("`fuse_groups` (length >= 2) is required when lambda_fus > 0.")
  }

  Dinfo <- .build_diff_matrix(p, group, fuse_groups)
  D     <- Dinfo$D
  K     <- Dinfo$K
  M     <- Dinfo$M

  ## Pick lambda by BIC on the unfused path if not given.
  if (is.null(lambda)) {
    anchor <- .sgl_bic(X, y, group, alpha, intercept = FALSE)
    lambda <- anchor$lambda
  }

  ## Group bookkeeping (matches sparsegl defaults).
  gi <- .group_columns(group)
  bs <- gi$bs
  bn <- gi$bn
  pf_group  <- sqrt(bs)              # default sparsegl pf_group
  pf_sparse <- rep(1, p)             # already sums to nvars, no rescale needed
  cum <- cumsum(c(0L, bs))
  group_cols <- lapply(seq_len(bn), function(g) seq.int(cum[g] + 1L, cum[g] + bs[g]))

  ## Pre-extract per-group X_g and D_g, and per-group Lipschitz constants
  ## L_g = max-eigenvalue of (X_g'X_g)/n + rho * D_g'D_g.
  Xg_list <- vector("list", bn)
  Dg_list <- vector("list", bn)
  Lg      <- numeric(bn)
  for (g in seq_len(bn)) {
    cg <- group_cols[[g]]
    Xg <- X[, cg, drop = FALSE]
    Dg <- D[, cg, drop = FALSE]
    Xg_list[[g]] <- Xg
    Dg_list[[g]] <- Dg
    A <- crossprod(Xg) / n + rho * crossprod(Dg)
    if (length(cg) == 1L) {
      Lg[g] <- as.numeric(A)
    } else {
      Lg[g] <- max(eigen(A, symmetric = TRUE, only.values = TRUE)$values)
    }
  }
  Lg <- pmax(Lg, 1e-12)

  lama   <- alpha * lambda
  lam1ma <- (1 - alpha) * lambda

  ## Inner b-update: block coordinate descent on
  ##   (1/(2n))||y - Xb||^2 + (rho/2)||Db - v||^2 + SGL(b)
  ## Maintains residuals r = y - X b and q = D b - v incrementally.
  inner_bcd <- function(beta_init, v, max_inner = 100L, inner_tol = 1e-9) {
    beta <- beta_init
    r <- as.numeric(y - X %*% beta)
    q <- as.numeric(D %*% beta - v)
    for (it_in in seq_len(max_inner)) {
      max_change <- 0
      for (g in seq_len(bn)) {
        cg <- group_cols[[g]]
        Xg <- Xg_list[[g]]
        Dg <- Dg_list[[g]]
        bg_old <- beta[cg]
        ## gradient of smooth part wrt b_g: -(1/n) X_g' r + rho D_g' q
        grad_g <- -as.numeric(crossprod(Xg, r)) / n +
                  rho * as.numeric(crossprod(Dg, q))
        t_g <- 1 / Lg[g]
        s   <- bg_old - t_g * grad_g
        ## L1 soft-threshold (per-coordinate).
        thr_l1 <- t_g * lama * pf_sparse[cg]
        s <- sign(s) * pmax(abs(s) - thr_l1, 0)
        ## group threshold.
        snorm <- sqrt(sum(s * s))
        thr_g <- t_g * lam1ma * pf_group[g]
        if (snorm > thr_g) {
          bg_new <- s * (1 - thr_g / snorm)
        } else {
          bg_new <- numeric(length(cg))
        }
        d <- bg_new - bg_old
        if (any(d != 0)) {
          beta[cg] <- bg_new
          r <- r - as.numeric(Xg %*% d)
          q <- q + as.numeric(Dg %*% d)
          ch <- Lg[g] * sum(d * d)
          if (ch > max_change) max_change <- ch
        }
      }
      if (max_change < inner_tol) break
    }
    beta
  }

  beta <- rep(0, p)
  Db   <- as.numeric(D %*% beta)
  z    <- Db
  u    <- rep(0, length(z))           # scaled dual

  thresh <- lambda_fus / rho
  iter   <- 0L
  converged <- FALSE
  for (it in seq_len(max_iter)) {
    iter <- it
    ## b-update via block coordinate descent (warm-started from previous beta).
    v    <- z + u
    beta <- inner_bcd(beta, v)
    Db   <- as.numeric(D %*% beta)

    ## z-update: blockwise group-soft-threshold.
    z_old  <- z
    target <- Db - u
    z      <- numeric(length(target))
    for (m in seq_len(M - 1L)) {
      idx <- ((m - 1L) * K + 1L):(m * K)
      tm  <- target[idx]
      nm  <- sqrt(sum(tm * tm))
      if (nm > thresh) z[idx] <- tm * (1 - thresh / nm)
    }

    ## dual update.
    u <- u + z - Db

    ## stopping criterion (Boyd et al. 2011 style).
    pri_res <- sqrt(sum((Db - z)^2))
    dua_res <- rho * sqrt(sum((z - z_old)^2))
    pri_tol <- tol * sqrt(length(z) + 1)
    dua_tol <- tol * sqrt(p + 1)

    if (verbose && (it %% 10 == 0 || it == 1)) {
      cat(sprintf("[fused_sgl] iter=%4d  pri=%.3e  dua=%.3e\n",
                  it, pri_res, dua_res))
    }
    if (pri_res < pri_tol && dua_res < dua_tol) {
      converged <- TRUE
      break
    }
  }

  fitted <- as.numeric(X %*% beta)
  df     <- sum(abs(beta) > 1e-8)
  info   <- .bic_from_coef(y, fitted, df, n)

  list(
    beta          = beta,
    b0            = 0,
    lambda        = lambda,
    lambda_fus    = lambda_fus,
    alpha         = alpha,
    bic           = info$bic,
    mse           = info$mse,
    df            = df,
    iters         = iter,
    converged     = converged,
    change_points = .detect_change_points(beta, group, fuse_groups, cp_tol)
  )
}

# ---- grid-search wrapper ----------------------------------------------------

#' Joint BIC selection of (alpha, lambda, lambda_fus).
#'
#' For each (alpha, lambda_fus), the lambda grid is taken from a fresh
#' sparsegl path at that alpha (with lambda_fus = 0). For lambda_fus = 0
#' we let `.sgl_bic` pick lambda directly, otherwise each lambda is tried.
fused_sgl_grid <- function(X, y, group,
                           alpha_grid      = c(0.5, 0.75, 0.9, 0.95),
                           lambda_fus_grid = c(0, 1e-3, 1e-2, 1e-1),
                           fuse_groups     = NULL,
                           intercept       = FALSE,
                           nlambda         = 30L,
                           verbose         = FALSE,
                           ...) {
  records <- list()
  best <- NULL
  best_bic <- Inf

  for (a in alpha_grid) {
    path <- sparsegl::sparsegl(
      x = X, y = y, group = group, asparse = a,
      intercept = intercept, nlambda = nlambda
    )
    lam_grid <- path$lambda

    for (lf in lambda_fus_grid) {
      if (lf == 0) {
        r <- fused_sgl(X, y, group, alpha = a, lambda = NULL,
                       lambda_fus = 0, fuse_groups = fuse_groups,
                       intercept = intercept, ...)
        records[[length(records) + 1L]] <-
          data.frame(alpha = a, lambda = r$lambda, lambda_fus = 0,
                     bic = r$bic, df = r$df)
        if (r$bic < best_bic) { best_bic <- r$bic; best <- r }
      } else {
        for (lam in lam_grid) {
          r <- tryCatch(
            fused_sgl(X, y, group, alpha = a, lambda = lam,
                      lambda_fus = lf, fuse_groups = fuse_groups,
                      intercept = intercept, verbose = FALSE, ...),
            error = function(e) NULL
          )
          if (is.null(r)) next
          records[[length(records) + 1L]] <-
            data.frame(alpha = a, lambda = lam, lambda_fus = lf,
                       bic = r$bic, df = r$df)
          if (verbose) {
            cat(sprintf("a=%.2f lf=%.2e lam=%.4g  bic=%.4f\n",
                        a, lf, lam, r$bic))
          }
          if (r$bic < best_bic) { best_bic <- r$bic; best <- r }
        }
      }
    }
  }
  best$grid <- do.call(rbind, records)
  best
}
