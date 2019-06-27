
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bayesims

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.com/lifecycle/#experimental)
[![Travis-CI Build
Status](https://travis-ci.com/poissonconsulting/bayesims.svg?branch=master)](https://travis-ci.com/poissonconsulting/bayesims)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/poissonconsulting/bayesims?branch=master&svg=true)](https://ci.appveyor.com/project/poissonconsulting/bayesims)
[![Coverage
Status](https://img.shields.io/codecov/c/github/poissonconsulting/bayesims/master.svg)](https://codecov.io/github/poissonconsulting/bayesims?branch=master)
<!-- badges: end -->

bayesims is an R package to simulate and analyse data using JAGS.

## Installation

To install the development version from the Poisson drat
[repository](https://github.com/poissonconsulting/drat)

``` r
install.packages("bayesims", repos = "http://poissonconsulting.github.io/drat")
```

## Demonstration

### Simulate Data

The `bsm_simulate_data()` function allows the user to simulate data
using JAGS model code.

It returns the simulated data values in the form of a single chain
`mcmcr::mcmcr` object where each iteration represents one sample.

``` r
library(bayesims)
set.seed(10L)
bsm_simulate_data("a ~ dunif(0,1)", nsamples = 1L)
#> $a
#> [1] 0.2132815
#> 
#> nchains:  1 
#> niters:  1
```
