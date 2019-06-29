
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

It returns the simulated data values in the form of a single chain
`mcmcr::mcmcr` object where each iteration represents one sample.

``` r
library(sims)
set.seed(10L)
sims_nlist("a ~ dunif(0,1)", nsims = 1L)
#> Registered S3 method overwritten by 'rjags':
#>   method               from 
#>   as.mcmc.list.mcarray mcmcr
#> $a
#> [1] 0.2132815
#> 
#> nchains:  1 
#> niters:  1
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
 results$C[1,,]
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]   42   40   26   30   31
#> [2,]   28   33   23   25   32
#> [3,]   28   33   32   25   34
#> [4,]   24   25   28   37   22
#> [5,]   33   27   25   25   13
 results$rand[1,,]
#> [1]  0.3628946 -0.7469995  1.2548191  1.0910107  0.1170109
 
 #Now I want to present those in the following format so I can pass them as data to JAGS for the analysis
 
  f1<- function(r){
     n <- length(names(results))
     lst <- lapply(1:n, function(i) results[[i]][1,r,])
     names(lst) <- names(results)
     return(lst)}
  lapply(1:nsims, f1)
#> [[1]]
#> [[1]]$C
#> [1] 42 40 26 30 31
#> 
#> [[1]]$rand
#> [1] 0.3628946
#> 
#> 
#> [[2]]
#> [[2]]$C
#> [1] 28 33 23 25 32
#> 
#> [[2]]$rand
#> [1] -0.7469995
#> 
#> 
#> [[3]]
#> [[3]]$C
#> [1] 28 33 32 25 34
#> 
#> [[3]]$rand
#> [1] 1.254819
#> 
#> 
#> [[4]]
#> [[4]]$C
#> [1] 24 25 28 37 22
#> 
#> [[4]]$rand
#> [1] 1.091011
#> 
#> 
#> [[5]]
#> [[5]]$C
#> [1] 33 27 25 25 13
#> 
#> [[5]]$rand
#> [1] 0.1170109
```
