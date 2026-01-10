# Plot cross-validation curves produced from a `cv.sparsegl` object.

Plots the average cross-validation error and upper and lower 1 standard
error bars. Dashed lines indicate the lambda that optimizes the CV error
and the 1 standard error lambda.

## Usage

``` r
# S3 method for class 'cv.sparsegl'
plot(x, log_axis = c("xy", "x", "y", "none"), sign.lambda = 1, ...)
```

## Arguments

- x:

  Fitted `"cv.sparsegl"` object, produced with
  [`cv.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/cv.sparsegl.md).

- log_axis:

  Apply log scaling to the requested axes.

- sign.lambda:

  Either plot against `log(lambda)` (default) or the reverse if
  `sign.lambda < 0`.

- ...:

  Not used.

## Details

A
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
plot is produced. Additional user modifications may be added as desired.

## See also

[`cv.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/cv.sparsegl.md).

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
plot(cv_fit)
```
