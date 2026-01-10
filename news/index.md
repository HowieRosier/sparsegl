# Changelog

## sparsegl (development version)

- Force `weights` to sum to `nobs` for all IRWLS cases.
- Remove `magrittr` from imports
- Add `auc` option for CV and binomial
- Address [\#59](https://github.com/dajmcdon/sparsegl/issues/59)
  ([@kaichen](https://github.com/kaichen))

## sparsegl 1.1.1

CRAN release: 2024-08-24

- Add CITATION and links to JSS article

## sparsegl 1.1.0

CRAN release: 2024-06-26

- Address some CRAN issues for FORTRAN builds on GCC 14.1

## sparsegl 1.0.2

CRAN release: 2023-09-25

- Corrects a bug / adds support for `weights` and `offset` in cv
- Some minor tweaks to error and warning messages

## sparsegl 1.0.1

CRAN release: 2023-01-27

- Remove unnecessary attributes from the included data

## sparsegl 1.0.0

CRAN release: 2022-11-28

- Improved documentation
- Added functionality to implement arbitrary
  [`stats::family()`](https://rdrr.io/r/stats/family.html) fitting.
- Enhanced (and corrected) S3 interface for `predict` and `coef`
  methods.

## sparsegl 0.5.0

CRAN release: 2022-09-22

- Minor internal updates to pass additional CRAN checks
- Refactor some documentation
- Intercept calculation is internal to Fortran source in all cases.

## sparsegl 0.4.0

CRAN release: 2022-09-05

- Add the option to weight individual coefficients in the l1 penalty.
- Remove coercions of the type `as(<matrix>, "dgCMatrix")`. These are
  deprecated in [Matrix](https://Matrix.R-forge.R-project.org)\>=1.4-2
  and will Warn on CRAN checks.
- Compute MSE internally in Fortran for `family = "Gaussian"`. Avoids
  the creation of a potentially large matrix of predicted values for the
  purposes of risk estimation.
- Revise
  [`estimate_risk()`](https://dajmcdon.github.io/sparsegl/reference/estimate_risk.md)
  signature. Now `x` is optional and `y` is not required.

## sparsegl 0.3.0

CRAN release: 2022-03-07

- Initial version on CRAN.
