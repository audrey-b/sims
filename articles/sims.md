# Get Started with sims

sims is an R package to generate datasets from
[JAGS](https://mcmc-jags.sourceforge.io/) or R code for use in
simulation studies.

## Simulating as `nlists` Objects

By default,
[`sims_simulate()`](https://poissonconsulting.github.io/sims/reference/sims_simulate.md)
returns the simulated datasets in the form of an
[nlists](https://github.com/poissonconsulting/nlist) object.

``` r

library(sims)
set.seed(10)
sims_simulate("a <- runif(1)", nsims = 2L)
#> $a
#> [1] 0.2213763
#> 
#> an nlists object of 2 nlist objects each with 1 numeric element
```

## Saving as `.rds` Files

If, however, `save = TRUE` then each nlist object is saved as an `.rds`
file in `path`.

``` r

set.seed(10)
sims_simulate("a <- runif(1)", nsims = 2L, save = TRUE, path = tempdir(), exists = NA)
#> [1] TRUE
sims_data_files(tempdir())
#> [1] "data0000001.rds" "data0000002.rds"
```

### Importing `.rds` Files

The datasets in the `.rds` files can be imported as an `nlists` object
using
[`sims_data()`](https://poissonconsulting.github.io/sims/reference/sims_data.md).

``` r

sims_data(tempdir())
#> $a
#> [1] 0.2213763
#> 
#> an nlists object of 2 nlist objects each with 1 numeric element
```

### Adding `.rds` Files

The values including the `.Random.seed` (not printed) that were used to
generate the datasets are saved in `.sims_args.rds` which can be
imported using
[`sims_info()`](https://poissonconsulting.github.io/sims/reference/sims_info.md).

``` r

sims_info(tempdir())[1:5]
#> $code
#> [1] "a <- runif(1)"
#> 
#> $constants
#> an nlist object with 0 numeric elements
#> 
#> $parameters
#> an nlist object with 0 numeric elements
#> 
#> $monitor
#> [1] "a"
#> 
#> $nsims
#> [1] 2
```

The fact that the arguments to
[`sims_simulate()`](https://poissonconsulting.github.io/sims/reference/sims_simulate.md)
are saved to file allows additional `.rds` datasets to be generated
using
[`sims_add()`](https://poissonconsulting.github.io/sims/reference/sims_add.md).

``` r

sims_add(tempdir(), nsims = 3L)
#> [1] "data0000003.rds" "data0000004.rds" "data0000005.rds"
sims_data_files(tempdir())
#> [1] "data0000001.rds" "data0000002.rds" "data0000003.rds" "data0000004.rds"
#> [5] "data0000005.rds"
```

### Copying `.rds` Files

If the user wishes to duplicate the datasets then they can either
regenerate them by specifying a different path but the same seed (using
[`set.seed()`](https://rdrr.io/r/base/Random.html)). Alternatively, they
can copy the existing `.sims.rds` and datasets files to a new directory
using
[`sims_copy()`](https://poissonconsulting.github.io/sims/reference/sims_copy.md)

``` r

sims_copy(path_from = tempdir(), path_to = paste0(tempdir(), "_copy"))
#> [1] "data0000001.rds" "data0000002.rds" "data0000003.rds" "data0000004.rds"
#> [5] "data0000005.rds"
```

### Checking `.rds` Files

A user can check that all the datasets specified in `.sims.rds` are
present using
[`sims_check()`](https://poissonconsulting.github.io/sims/reference/sims_check.md).

``` r

sims_check(path = paste0(tempdir(), "_copy"))
```

``` r

file.remove(file.path(paste0(tempdir(), "_copy"), "data0000005.rds"))
#> [1] TRUE

sims_check(path = paste0(tempdir(), "_copy"))
#> Error:
#> ! Number of data files (4) does not match number of simulations (5).
```

## Parallelization

Parallelization is implemented using the
[future](https://github.com/HenrikBengtsson/future) package.

To use all available cores on the local machine simply execute the
following code before calling
[`sims_simulate()`](https://poissonconsulting.github.io/sims/reference/sims_simulate.md).

``` r

library(future)
plan(multisession)
```

``` r

set.seed(10)
sims_simulate("a <- runif(1)", nsims = 2L)
#> $a
#> [1] 0.2213763
#> 
#> an nlists object of 2 nlist objects each with 1 numeric element
```

## Progress

Progress is reported using the
[progressr](https://github.com/HenrikBengtsson/progressr) package as
follows.

``` r

library(progressr)
with_progress(sims_simulate("a <- runif(1)", nsims = 1000L))
#> $a
#> [1] 0.5248719
#> 
#> an nlists object of 1000 nlist objects each with 1 numeric element
```
