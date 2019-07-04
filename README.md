
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sims

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.com/lifecycle/#experimental)
[![Travis-CI Build
Status](https://travis-ci.com/poissonconsulting/sims.svg?branch=master)](https://travis-ci.com/poissonconsulting/sims)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/sims?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/sims)
[![Coverage
Status](https://img.shields.io/codecov/c/github/poissonconsulting/sims/master.svg)](https://codecov.io/github/poissonconsulting/sims?branch=master)
<!-- badges: end -->

sims is an R package to simulate, save and manipulate datasets. The
generative model is specified using a fragment of JAGS code.

## Installation

To install the latest development version from
[GitHub](https://github.com/poissonconsulting/sims)

    remotes::install_github("poissonconsulting/sims")

## Demonstration

``` r
library(sims)
set.seed(10L)

generative_model <- "
rand ~ dnorm(0,1)
for (i in 1:length(Year)){
  C[i] ~ dpois(lambda[i])
  log(lambda[i]) <- alpha + beta1 * Year[i]
}
"

parameters <- list(alpha = 3.5576, beta1 = -0.0912)

constants <- list(Year = 1:5)

results <- sims_generate(generative_model, 
                         constants = constants,
                         parameters = parameters)

results
#> $C
#> [1] 32.09 29.10 27.44 24.06 21.88
#> 
#> $lambda
#> [1] 32.02126 29.23013 26.68229 24.35653 22.23350
#> 
#> $rand
#> [1] 0.1313937
#> 
#> $Year
#> [1] 1 2 3 4 5
#> 
#> an nlists object of 100 nlist objects each with 4 natomic elements

results[[1]]
#> $C
#> [1] 38 30 22 20 17
#> 
#> $lambda
#> [1] 32.02126 29.23013 26.68229 24.35653 22.23350
#> 
#> $rand
#> [1] 0.8400557
#> 
#> $Year
#> [1] 1 2 3 4 5
#> 
#> an nlist object with 4 natomic elements
```

### Simulate Data

By default, `sims_generate()` returns the simulated datasets in the form
of an nlists object.

``` r
library(sims)
set.seed(10)
sims_generate("a ~ dunif(0,1)", nsims = 2L)
#> $a
#> [1] 0.6837434
#> 
#> an nlists object of 2 nlist objects each with 1 natomic element
```

If, however, `write = TRUE` then each nlist object is saved as an `.rds`
files. The information used to generate the datasets is saved in
`.argsims.rds`.

``` r
set.seed(10)
sims_generate("a ~ dunif(0,1)", nsims = 2L,
              write = TRUE, path = tempdir(), exists = NA)
#> [1] "data0000001.rds" "data0000002.rds"
```

The fact that the arguments to sims\_generate() are saved in
`.argsims.rds` allows additional datasets to be generated using
`sims_add()`.

``` r
sims_add(path = tempdir(), nsims = 3L)
#> [1] "data0000003.rds" "data0000004.rds" "data0000005.rds"
```

If the user wishes to duplicate the datasets then they can either
regenerate them by specifying a different path but the same key.
Alternatively, they can copy the existing `.argsims.rds` and datasets
files to a new directory using `sims_copy()`

``` r
sims_copy(path_from = tempdir(), path_to = paste0(tempdir(), "_copy"))
#> [1] "data0000001.rds" "data0000002.rds" "data0000003.rds" "data0000004.rds"
#> [5] "data0000005.rds"
```

A user can check that all the datasets specified in `.argsims.rds` are
present using `sims_check()`.

``` r
sims_check(path = paste0(tempdir(), "_copy"))
#> $code
#> [1] "model{a ~ dunif(0,1)}\n"
#> 
#> $constants
#> an nlist object with 0 natomic elements
#> $parameters
#> an nlist object with 0 natomic elements
#> $monitor
#> [1] "a"
#> 
#> $nsims
#> [1] 5
#> 
#> $seed
#> [1] 1089801142

file.remove(file.path(paste0(tempdir(), "_copy"), "data0000005.rds"))
#> [1] TRUE
```

``` r
sims_check(path = paste0(tempdir(), "_copy"))
#> Error: number of data files (4) does not match number of simulations (5)
```

# Contribution

Please report any
[issues](https://github.com/poissonconsulting/sims/issues).

[Pull requests](https://github.com/poissonconsulting/sims/pulls) are
always welcome.

Please note that the ‘sims’ project is released with a [Contributor Code
of
Conduct](https://poissonconsulting.github.io/sims/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.
