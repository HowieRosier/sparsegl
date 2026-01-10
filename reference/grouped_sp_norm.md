# Calculate common norms

Calculate different norms of vectors with or without grouping
structures.

## Usage

``` r
zero_norm(x)

one_norm(x)

two_norm(x)

grouped_zero_norm(x, gr)

grouped_one_norm(x, gr)

grouped_two_norm(x, gr)

grouped_sp_norm(x, gr, asparse)

gr_one_norm(x, gr)

gr_two_norm(x, gr)

sp_group_norm(x, gr, asparse = 0.05)
```

## Arguments

- x:

  A numeric vector.

- gr:

  An integer (or factor) vector of the same length as x.

- asparse:

  Scalar. The weight to put on the l1 norm when calculating the group
  norm.

## Value

A numeric scalar or vector

## Functions

- `zero_norm()`: l0-norm (number of nonzero entries).

- `one_norm()`: l1-norm (Absolute-value norm).

- `two_norm()`: l2-norm (Euclidean norm).

- `grouped_zero_norm()`: A vector of group-wise l0-norms.

- `grouped_one_norm()`: A vector of group-wise l1-norms.

- `grouped_two_norm()`: A vector of group-wise l2-norms.

- `grouped_sp_norm()`: A vector of length `unique(gr)` consisting of the
  `asparse` convex combination of the l1 and l2-norm for each group.

- `gr_one_norm()`: The l1-norm norm of a vector (a scalar).

- `gr_two_norm()`: The sum of the group-wise l2-norms of a vector (a
  scalar).

- `sp_group_norm()`: The sum of the `asparse` convex combination of
  group l1 and l2-norms vectors (a scalar).

## Examples

``` r
x <- c(rep(-1, 5), rep(0, 5), rep(1, 5))
gr <- c(rep(1, 5), rep(2, 5), rep(3, 5))
asparse <- 0.05
grouped_sp_norm(x, gr, asparse)
#> [1] 2.374265 0.000000 2.374265
```
