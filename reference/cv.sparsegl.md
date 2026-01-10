# Cross-validation for a `sparsegl` object.

Performs k-fold cross-validation for
[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md).
This function is largely similar
[`glmnet::cv.glmnet()`](https://glmnet.stanford.edu/reference/cv.glmnet.html).

## Usage

``` r
cv.sparsegl(
  x,
  y,
  group = NULL,
  family = c("gaussian", "binomial"),
  lambda = NULL,
  pred.loss = c("default", "mse", "deviance", "mae", "misclass", "auc"),
  nfolds = 10,
  foldid = NULL,
  weights = NULL,
  offset = NULL,
  ...
)
```

## Arguments

- x:

  Double. A matrix of predictors, of dimension \\n \times p\\; each row
  is a vector of measurements and each column is a feature. Objects of
  class
  [`Matrix::sparseMatrix`](https://rdrr.io/pkg/Matrix/man/sparseMatrix.html)
  are supported.

- y:

  Double/Integer/Factor. The response variable. Quantitative for
  `family="gaussian"` and for other exponential families. If
  `family="binomial"` should be either a factor with two levels or a
  vector of integers taking 2 unique values. For a factor, the last
  level in alphabetical order is the target class.

- group:

  Integer. A vector of consecutive integers describing the grouping of
  the coefficients (see example below).

- family:

  Character or function. Specifies the generalized linear model to use.
  Valid options are:

  - `"gaussian"` - least squares loss (regression, the default),

  - `"binomial"` - logistic loss (classification)

  For any other type, a valid
  [`stats::family()`](https://rdrr.io/r/stats/family.html) object may be
  passed. Note that these will generally be much slower to estimate than
  the built-in options passed as strings. So for example,
  `family = "gaussian"` and `family = gaussian()` will produce the same
  results, but the first will be much faster.

- lambda:

  A user supplied `lambda` sequence. The default, `NULL` results in an
  automatic computation based on `nlambda`, the smallest value of
  `lambda` that would give the null model (all coefficient estimates
  equal to zero), and `lambda.factor`. Supplying a value of `lambda`
  overrides this behaviour. It is likely better to supply a decreasing
  sequence of `lambda` values than a single (small) value. If supplied,
  the user-defined `lambda` sequence is automatically sorted in
  decreasing order.

- pred.loss:

  Loss to use for cross-validation error. Valid options are:

  - `"default"` the same as deviance (mse for regression and deviance
    otherwise)

  - `"mse"` mean square error

  - `"deviance"` the default (mse for Gaussian regression, and negative
    log-likelihood otherwise)

  - `"mae"` mean absolute error, can apply to any family

  - `"misclass"` for classification only, misclassification error.

  - `"auc"` for classification only, area under the ROC curve

- nfolds:

  Number of folds - default is 10. Although `nfolds` can be as large as
  the sample size (leave-one-out CV), it is not recommended for large
  datasets. Smallest value allowable is `nfolds = 3`.

- foldid:

  An optional vector of values between 1 and `nfolds` identifying which
  fold each observation is in. If supplied, `nfolds` can be missing.

- weights:

  Double vector. Optional observation weights. These can only be used
  with a [`stats::family()`](https://rdrr.io/r/stats/family.html)
  object. Internally coerced to sum to the number of observations.

- offset:

  Double vector. Optional offset (constant predictor without a
  corresponding coefficient). These can only be used with a
  [`stats::family()`](https://rdrr.io/r/stats/family.html) object.

- ...:

  Additional arguments to
  [`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md).

## Value

An object of class `cv.sparsegl()` is returned, which is a list with the
components describing the cross-validation error.

- lambda:

  The values of `lambda` used in the fits.

- cvm:

  The mean cross-validated error - a vector of length `length(lambda)`.

- cvsd:

  Estimate of standard error of `cvm`.

- cvupper:

  Upper curve = `cvm + cvsd`.

- cvlower:

  Lower curve = `cvm - cvsd`.

- name:

  A text string indicating type of measure (for plotting purposes).

- nnzero:

  The number of non-zero coefficients for each `lambda`

- active_grps:

  The number of active groups for each `lambda`

- sparsegl.fit:

  A fitted
  [`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
  object for the full data.

- lambda.min:

  The optimal value of `lambda` that gives minimum cross validation
  error `cvm`.

- lambda.1se:

  The largest value of `lambda` such that error is within 1 standard
  error of the minimum.

- i.min:

  The index of `lambda.min` in the `lambda` sequence.

- i.1se:

  The index of `lambda.1se` in the `lambda` sequence.

- call:

  The function call.

## Details

The function runs
[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
`nfolds + 1` times; the first to get the `lambda` sequence, and then the
remainder to compute the fit with each of the folds omitted. The average
error and standard error over the folds are computed.

## References

Liang, X., Cohen, A., Sólon Heinsfeld, A., Pestilli, F., and McDonald,
D.J. 2024. *sparsegl: An `R` Package for Estimating Sparse Group Lasso.*
Journal of Statistical Software, Vol. 110(6): 1–23.
[doi:10.18637/jss.v110.i06](https://doi.org/10.18637/jss.v110.i06) .

## See also

[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md),
as well as
[`plot()`](https://dajmcdon.github.io/sparsegl/reference/plot.cv.sparsegl.md),
[`predict()`](https://dajmcdon.github.io/sparsegl/reference/predict.cv.sparsegl.md),
and
[`coef()`](https://dajmcdon.github.io/sparsegl/reference/coef.cv.sparsegl.md)
methods for `"cv.sparsegl"` objects.

## Examples

``` r
n <- 100
p <- 20
X <- matrix(rnorm(n * p), nrow = n)
eps <- rnorm(n)
beta_star <- c(rep(5, 5), c(5, -5, 2, 0, 0), rep(-5, 5), rep(0, (p - 15)))
y <- X %*% beta_star + eps
groups <- rep(1:(p / 5), each = 5)
cv_fit <- cv.sparsegl(X, y, groups)
```
