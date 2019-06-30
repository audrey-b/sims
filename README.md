
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

sims is an R package to simulate and analyse data using JAGS.

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

The `sims_nlist()` function allows the user to simulate data using JAGS
model code.

It returns the simulated data values in the form of a nlists object.

``` r
library(sims)
set.seed(10L)
sims_nlist("a ~ dunif(0,1)")
#> $a
#> [1] 0.5372814
#> 
#> an nlists object of 100 nlist objects each with 1 natomic element
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
 
 results <- sims_nlist(code=likelihood, constants=values, monitor=monitor, nsims=nsims)
 
 results
#> $C
#> [1] 31.0 31.6 26.8 28.4 26.4
#> 
#> $rand
#> [1] 0.4157472
#> 
#> an nlists object of 5 nlist objects each with 2 natomic elements
 
 results[,"C"]
#> $C
#> [1] 31.0 31.6 26.8 28.4 26.4
#> 
#> an nlists object of 5 nlist objects each with 1 natomic element
 results[,"rand"]
#> $rand
#> [1] 0.4157472
#> 
#> an nlists object of 5 nlist objects each with 1 natomic element
 
 #Now I want to present those in the following format so I can pass them as data to JAGS for the analysis
 # nlist objects should be able to be feed in element by element to JAGs models.
 
  str(results)
#> List of 5
#>  $ :List of 2
#>   ..$ C   : num [1:5] 42 40 26 30 31
#>   ..$ rand: num 0.363
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 2
#>   ..$ C   : num [1:5] 28 33 23 25 32
#>   ..$ rand: num -0.747
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 2
#>   ..$ C   : num [1:5] 28 33 32 25 34
#>   ..$ rand: num 1.25
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 2
#>   ..$ C   : num [1:5] 24 25 28 37 22
#>   ..$ rand: num 1.09
#>   ..- attr(*, "class")= chr "nlist"
#>  $ :List of 2
#>   ..$ C   : num [1:5] 33 27 25 25 13
#>   ..$ rand: num 0.117
#>   ..- attr(*, "class")= chr "nlist"
#>  - attr(*, "class")= chr "nlists"
```
