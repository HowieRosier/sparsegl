# Extract model coefficients from a `sparsegl` object.

Computes the coefficients at the requested value(s) for `lambda` from a
[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
object.

## Usage

``` r
# S3 method for class 'sparsegl'
coef(object, s = NULL, ...)
```

## Arguments

- object:

  Fitted
  [`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
  object.

- s:

  Value(s) of the penalty parameter `lambda` at which coefficients are
  required. Default is the entire sequence.

- ...:

  Not used.

## Value

The coefficients at the requested values for `lambda`.

## Details

`s` is the new vector of `lambda` values at which predictions are
requested. If `s` is not in the lambda sequence used for fitting the
model, the `coef` function will use linear interpolation to make
predictions. The new values are interpolated using a fraction of
coefficients from both left and right `lambda` indices.

## See also

[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
and
[`predict.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/predict.sparsegl.md).

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
coef(fit1, s = c(0.02, 0.03))
#> 21 x 2 sparse Matrix of class "dgCMatrix"
#>                      s1          s2
#> (Intercept) -0.01678224 -0.01682395
#> V1           4.91479976  4.80927045
#> V2           4.69948041  4.63159288
#> V3           4.74904120  4.59195270
#> V4           4.86288161  4.75231114
#> V5           4.75791348  4.69033508
#> V6           4.63961136  4.47714823
#> V7          -4.83278909 -4.69375932
#> V8           2.01590285  1.99479801
#> V9           0.05065353  0.08332983
#> V10         -0.14142640 -0.14644338
#> V11         -4.84730705 -4.77336356
#> V12         -4.66596967 -4.56115266
#> V13         -4.81352148 -4.71580151
#> V14         -4.79079945 -4.65722652
#> V15         -4.94137922 -4.86577000
#> V16          .           .         
#> V17          .           .         
#> V18          .           .         
#> V19          .           .         
#> V20          .           .         
```
