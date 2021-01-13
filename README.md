
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sims

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![R build
status](https://github.com/poissonconsulting/sims/workflows/R-CMD-check/badge.svg)](https://github.com/poissonconsulting/sims/actions)
[![Codecov test
coverage](https://codecov.io/gh/poissonconsulting/sims/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/sims?branch=master)
[![License:
MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![CRAN
status](https://www.r-pkg.org/badges/version/sims)](https://cran.r-project.org/package=sims)
![CRAN downloads](http://cranlogs.r-pkg.org/badges/sims)
<!-- badges: end -->

sims is an R package to generate datasets from R or
[JAGS](http://mcmc-jags.sourceforge.net) code for use in simulation
studies. The datasets are returned as an
[nlists](https://github.com/poissonconsulting/nlist) object and/or saved
to file as individual .rds files. Parallelization is implemented using
the [future](https://github.com/HenrikBengtsson/future) package.
Progress is reported using the
[progressr](https://github.com/HenrikBengtsson/progressr) package.

## Installation

To install the developmental version from
[GitHub](https://github.com/poissonconsulting/sims)

``` r
# install.packages("remotes")
remotes::install_github("poissonconsulting/sims")
```

## Demonstration

### Simulate Data

By default, `sims_simulate()` returns the simulated datasets in the form
of an [nlists](https://github.com/poissonconsulting/nlist) object.

``` r
library(sims)
set.seed(10)
sims_simulate("a ~ dunif(0,1)", nsims = 2L)
#> $a
#> [1] 0.6857306
#> 
#> an nlists object of 2 nlist objects each with 1 numeric element
```

If, however, `save = TRUE` then each nlist object is saved as an `.rds`
file in `path`.

``` r
set.seed(10)
sims_simulate("a ~ dunif(0,1)", nsims = 2L, save = TRUE, path = tempdir(), exists = NA)
#> [1] TRUE
sims_data_files(tempdir())
#> [1] "data0000001.rds" "data0000002.rds"
sims_data(tempdir())
#> $a
#> [1] 0.6857306
#> 
#> an nlists object of 2 nlist objects each with 1 numeric element
```

## Information

For more information see the [Get
Started](https://poissonconsulting.github.io/sims/articles/sims.html)
vignette.

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/sims/issues).

[Pull requests](https://github.com/poissonconsulting/sims/pulls) are
always welcome.

## Code of Conduct

Please note that the sims project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
