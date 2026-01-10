# Extract coefficients from a `cv.sparsegl` object.

This function etracts coefficients from a cross-validated
[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
model, using the stored `"sparsegl.fit"` object, and the optimal value
chosen for `lambda`.

## Usage

``` r
# S3 method for class 'cv.sparsegl'
coef(object, s = c("lambda.1se", "lambda.min"), ...)
```

## Arguments

- object:

  Fitted
  [`cv.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/cv.sparsegl.md)
  object.

- s:

  Value(s) of the penalty parameter `lambda` at which coefficients are
  desired. Default is the single value `s = "lambda.1se"` stored in the
  CV object (corresponding to the largest value of `lambda` such that CV
  error estimate is within 1 standard error of the minimum).
  Alternatively `s = "lambda.min"` can be used (corresponding to the
  minimum of cross validation error estimate). If `s` is numeric, it is
  taken as the value(s) of `lambda` to be used.

- ...:

  Not used.

## Value

The coefficients at the requested value(s) for `lambda`.

## See also

[`cv.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/cv.sparsegl.md)
and
[`predict.cv.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/predict.cv.sparsegl.md).

## Examples

``` r
n <- 100
p <- 20
X <- matrix(rnorm(n * p), nrow = n)
eps <- rnorm(n)
beta_star <- c(rep(5, 5), c(5, -5, 2, 0, 0), rep(-5, 5), rep(0, (p - 15)))
y <- X %*% beta_star + eps
groups <- rep(1:(p / 5), each = 5)
fit1 <- sparsegl(X, y, group = groups)
cv_fit <- cv.sparsegl(X, y, groups)
coef(cv_fit, s = c(0.02, 0.03))
#> 21 x 2 sparse Matrix of class "dgCMatrix"
#>                      s1          s2
#> (Intercept)  0.25058054  0.32798112
#> V1           4.69685440  4.61179702
#> V2           4.87498687  4.80778825
#> V3           4.79092864  4.70788964
#> V4           4.66068791  4.53530689
#> V5           4.63701728  4.47046037
#> V6           4.83517828  4.67359737
#> V7          -4.32100726 -4.09271636
#> V8           1.78185776  1.67848050
#> V9           0.04970934  0.08302102
#> V10          0.03184873  0.07964946
#> V11         -4.77143301 -4.67240455
#> V12         -4.92212465 -4.82991217
#> V13         -4.76996682 -4.59229699
#> V14         -4.95490098 -4.88966650
#> V15         -4.88915656 -4.79944906
#> V16          .           .         
#> V17          .           .         
#> V18          .           .         
#> V19          .           .         
#> V20          .           .         
```
