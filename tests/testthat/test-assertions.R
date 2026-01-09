test_that("`group` vctr is sorted", {
  X <- matrix(rnorm(20 * 5), nrow = 20)
  beta <- c(1, 1, 0, 0, 1)
  y <- X %*% beta + rnorm(20)
  group1 <- c(3, 3, 3, 1, 2)
  pf1 <- c(0, 2, 0)
  expect_snapshot(
    error = TRUE,
    sparsegl(X, y, group = group1, asparse = 0, pf_group = pf1)
  )
})
