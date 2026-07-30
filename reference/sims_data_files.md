# Simulated Data Files

Gets the names of the simulated data files.

## Usage

``` r
sims_data_files(path = ".")
```

## Arguments

- path:

  A string of the path to the directory with the simulated data.

## Value

A character vector of the names of the simulated data files.

## Examples

``` r
set.seed(10)
sims_simulate("a <- runif(1)",
  nsims = 10L, path = tempdir(),
  exists = NA, ask = FALSE
)
#> $a
#> [1] 0.3068346
#> 
#> an nlists object of 10 nlist objects each with 1 numeric element
sims_data_files(tempdir())
#> [1] "data0000001.rds"
```
