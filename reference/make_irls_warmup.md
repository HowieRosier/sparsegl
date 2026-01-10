# Create starting values for iterative reweighted least squares

This function may be used to create potentially valid starting values
for calling
[`sparsegl()`](https://dajmcdon.github.io/sparsegl/reference/sparsegl.md)
with a [`stats::family()`](https://rdrr.io/r/stats/family.html) object.
It is not typically necessary to call this function (as it is used
internally to create some), but in some cases, especially with custom
generalized linear models, it may improve performance.

## Usage

``` r
make_irls_warmup(nobs, nvars, b0 = 0, beta = double(nvars), r = double(nobs))
```

## Arguments

- nobs:

  Number of observations in the response (or rows in `x`).

- nvars:

  Number of columns in `x`

- b0:

  Scalar. Initial value for the intercept.

- beta:

  Vector. Initial values for the coefficients. Must be length `nvars`
  (or a scalar).

- r:

  Vector. Initial values for the deviance residuals. Must be length
  `nobs` (or a scalar).

## Value

List of class `irlsspgl_warmup`

## Details

Occasionally, the irls fitting routine may fail with an admonition to
create valid starting values.
