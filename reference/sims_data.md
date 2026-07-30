# Simulated Datasets

Gets the simulated datasets as an
[`nlist::nlists_object()`](https://rdrr.io/pkg/nlist/man/nlists.html).
There is no guarantee that all the datasets will fit in memory.

## Usage

``` r
sims_data(path = ".")
```

## Arguments

- path:

  A string of the path to the directory with the simulated data.

## Value

An [`nlist::nlists_object()`](https://rdrr.io/pkg/nlist/man/nlists.html)
of the simulated datasets.

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
library(nlist)
sims_data(tempdir())
#> $a
#> [1] 0.2909775
#> 
#> an nlists object of an nlist object with 1 numeric element
```
