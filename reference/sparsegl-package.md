# sparsegl: Sparse Group Lasso

Efficient implementation of sparse group lasso with optional bound
constraints on the coefficients; see Liang, et al., (2024)
[doi:10.18637/jss.v110.i06](https://doi.org/10.18637/jss.v110.i06) . It
supports the use of a sparse design matrix as well as returning
coefficient estimates in a sparse matrix. Furthermore, it correctly
calculates the degrees of freedom to allow for information criteria
rather than cross-validation with very large data. Finally, the
interface to compiled code avoids unnecessary copies and allows for the
use of long integers.

## References

Liang, X., Cohen, A., Sólon Heinsfeld, A., Pestilli, F., and McDonald,
D.J. 2024. "sparsegl: An `R` Package for Estimating Sparse Group Lasso."
*Journal of Statistical Software*, **110**(6): 1–23.
[doi:10.18637/jss.v110.i06](https://doi.org/10.18637/jss.v110.i06).

## See also

Useful links:

- <https://github.com/dajmcdon/sparsegl>

- <https://dajmcdon.github.io/sparsegl/>

- Report bugs at <https://github.com/dajmcdon/sparsegl/issues>

## Author

**Maintainer**: Daniel J. McDonald <daniel@stat.ubc.ca> \[copyright
holder\]

Authors:

- Xiaoxuan Liang <xiaoxuan.liang@stat.ubc.ca>

- Anibal Solón Heinsfeld <anibalsolon@gmail.com>

- Aaron Cohen <cohenaa@indiana.edu>

Other contributors:

- Yi Yang <yi.yang6@mcgill.ca> \[contributor\]

- Hui Zou \[contributor\]

- Jerome Friedman \[contributor\]

- Trevor Hastie \[contributor\]

- Rob Tibshirani \[contributor\]

- Balasubramanian Narasimhan \[contributor\]

- Kenneth Tay \[contributor\]

- Noah Simon \[contributor\]

- Junyang Qian \[contributor\]

- James Yang \[contributor\]
