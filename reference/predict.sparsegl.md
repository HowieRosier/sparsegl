# Make predictions from a `sparsegl` object.

Similar to other predict methods, this function produces fitted values
and class labels from a fitted
[`sparsegl`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
object.

## Usage

``` r
# S3 method for class 'sparsegl'
predict(
  object,
  newx,
  s = NULL,
  type = c("link", "response", "coefficients", "nonzero", "class"),
  ...
)
```

## Arguments

- object:

  Fitted
  [`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
  model object.

- newx:

  Matrix of new values for `x` at which predictions are to be made. Must
  be a matrix. This argument is mandatory.

- s:

  Value(s) of the penalty parameter `lambda` at which predictions are
  required. Default is the entire sequence used to create the model.

- type:

  Type of prediction required. Type `"link"` gives the linear predictors
  for `"binomial"`; for `"gaussian"` models it gives the fitted values.
  Type `"response"` gives predictions on the scale of the response (for
  example, fitted probabilities for `"binomial"`); for `"gaussian"` type
  `"response"` is equivalent to type `"link"`. Type `"coefficients"`
  computes the coefficients at the requested values for `s`. Type
  `"class"` applies only to `"binomial"` models, and produces the class
  label corresponding to the maximum probability. Type `"nonzero"`
  returns a list of the indices of the nonzero coefficients for each
  value of `s`.

- ...:

  Not used.

## Value

The object returned depends on type.

## Details

`s` is the new vector of `lambda` values at which predictions are
requested. If `s` is not in the lambda sequence used for fitting the
model, the `coef` function will use linear interpolation to make
predictions. The new values are interpolated using a fraction of
coefficients from both left and right `lambda` indices.

## See also

[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md),
[`coef.sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/coef.sparsegl.md).

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
predict(fit1, newx = X[10, ], s = fit1$lambda[3:5])
#>             s1        s2         s3
#> [1,] -1.325783 -1.009143 -0.8451558
```
