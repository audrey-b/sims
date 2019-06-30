
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
[GitHub](https://github.com/poissonconsulting/bayessims)

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
