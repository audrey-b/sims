
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

sims is an R package to simulate and manipulate datasets.

## Installation

To install the latest development version from
[GitHub](https://github.com/poissonconsulting/sims)

    remotes::install_github("poissonconsulting/sims")

To install the latest development version from the Poisson drat
[repository](https://github.com/poissonconsulting/drat)

    drat::addRepo("poissonconsulting")
    install.packages("sims")

## Demonstration

### Simulate Data

The `sims_generate()` function allows the user to simulate data using
JAGS model code.

By default, it returns the simulated datasets in the form of a nlists
object.

``` r
library(sims)
set.seed(10)
sims_generate("a ~ dunif(0,1)", nsims = 2L)
#> $a
#> [1] 0.6837434
#> 
#> an nlists object of 2 nlist objects each with 1 natomic element
```

If `write = TRUE` then the datasets are saved as `.rds` files. The key
sims\_generate function arguments are saved in `argsims.rds`.

``` r
set.seed(10)
sims_generate("a ~ dunif(0,1)", nsims = 2L,
                       write = TRUE, path = tempdir(), exists = NA)
#> [1] "argsims.rds"     "data0000001.rds" "data0000002.rds"
```

Additional datasets can be generated using `sims_add()`

``` r
sims_add(path = tempdir(), nsims = 3L)
#> [1] "argsims.rds"     "data0000003.rds" "data0000004.rds" "data0000005.rds"
```

And the argsims and data files copied to a new directory using
`sims_copy()`

``` r
sims_copy(path_from = tempdir(), path_to = paste0(tempdir(), "_copy"))
#> [1] "argsims.rds"     "data0000001.rds" "data0000002.rds" "data0000003.rds"
#> [5] "data0000004.rds" "data0000005.rds"
```

The internal consistency of a set of generated data can be queried using
`sims_check()`.

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
```

``` r
library(sims)
set.seed(10L)

likelihood <- "
 # Likelihood: Note key components of a GLM on one line each
 rand ~ dnorm(0,1)
 for (i in 1:n){
   C[i] ~ dpois(lambda[i])          # 1. Distribution for random part
   log(lambda[i]) <- log.lambda[i]  # 2. Link function
   log.lambda[i] <- alpha + beta1 * year[i] + beta2 * pow(year[i],2) + beta3 * pow(year[i],3)                      # 3. Linear predictor
   } #i
 "
 monitor=c("C", "rand")

 values <- list(alpha = 3.5576,
                beta1 = -0.0912,
                beta2 = 0.0091,
                beta3 = -0.00014,
                n = 5,
                year = 1:5)
 
 nsims=5
 
 results <- sims_generate(code=likelihood, constants=values, monitor=monitor, nsims=nsims)
 
 results
#> $C
#> [1] 35.4 29.4 28.6 27.2 21.2
#> 
#> $rand
#> [1] -0.110703
#> 
#> $alpha
#> [1] 3.5576
#> 
#> $beta1
#> [1] -0.0912
#> 
#> $beta2
#> [1] 0.0091
#> 
#> $beta3
#> [1] -0.00014
#> 
#> $n
#> [1] 5
#> 
#> $year
#> [1] 1 2 3 4 5
#> 
#> an nlists object of 5 nlist objects each with 8 natomic elements
 
 results[,"C"]
#> $C
#> [1] 35.4 29.4 28.6 27.2 21.2
#> 
#> an nlists object of 5 nlist objects each with 1 natomic element
 results[,"rand"]
#> $rand
#> [1] -0.110703
#> 
#> an nlists object of 5 nlist objects each with 1 natomic element
 
 #Now I want to present those in the following format so I can pass them as data to JAGS for the analysis
 # nlist objects should be able to be feed in element by element to JAGs models.
 
  str(results)
#> List of 5
#>  $ :List of 8
#>   ..$ C    : num [1:5] 39 31 24 23 21
#>   ..$ rand : num 0.84
#>   ..$ alpha: num 3.56
#>   ..$ beta1: num -0.0912
#>   ..$ beta2: num 0.0091
#>   ..$ beta3: num -0.00014
#>   ..$ n    : num 5
#>   ..$ year : int [1:5] 1 2 3 4 5
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 8
#>   ..$ C    : num [1:5] 38 34 31 34 15
#>   ..$ rand : num -0.0843
#>   ..$ alpha: num 3.56
#>   ..$ beta1: num -0.0912
#>   ..$ beta2: num 0.0091
#>   ..$ beta3: num -0.00014
#>   ..$ n    : num 5
#>   ..$ year : int [1:5] 1 2 3 4 5
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 8
#>   ..$ C    : num [1:5] 33 29 32 28 29
#>   ..$ rand : num -0.318
#>   ..$ alpha: num 3.56
#>   ..$ beta1: num -0.0912
#>   ..$ beta2: num 0.0091
#>   ..$ beta3: num -0.00014
#>   ..$ n    : num 5
#>   ..$ year : int [1:5] 1 2 3 4 5
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 8
#>   ..$ C    : num [1:5] 39 24 34 22 21
#>   ..$ rand : num -1.04
#>   ..$ alpha: num 3.56
#>   ..$ beta1: num -0.0912
#>   ..$ beta2: num 0.0091
#>   ..$ beta3: num -0.00014
#>   ..$ n    : num 5
#>   ..$ year : int [1:5] 1 2 3 4 5
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 8
#>   ..$ C    : num [1:5] 28 29 22 29 20
#>   ..$ rand : num 0.0522
#>   ..$ alpha: num 3.56
#>   ..$ beta1: num -0.0912
#>   ..$ beta2: num 0.0091
#>   ..$ beta3: num -0.00014
#>   ..$ n    : num 5
#>   ..$ year : int [1:5] 1 2 3 4 5
#>   ..- attr(*, "class")= chr "nlist"
#>  - attr(*, "class")= chr "nlists"
```
