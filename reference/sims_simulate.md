# Simulate Datasets

Simulates datasets using JAGS or R code. By default returns the datasets
as an
[`nlist::nlists_object()`](https://rdrr.io/pkg/nlist/man/nlists.html).
If `path` is provided then the datasets are written to the directory as
individual `.rds` files.

## Usage

``` r
sims_simulate(
  code,
  constants = nlist::nlist(),
  parameters = nlist::nlist(),
  monitor = ".*",
  stochastic = NA,
  latent = NA,
  nsims = 1,
  save = FALSE,
  path = ".",
  exists = FALSE,
  rdists = sims_rdists(),
  ask = getOption("sims.ask", TRUE),
  silent = FALSE
)
```

## Arguments

- code:

  A string of the JAGS or R code to generate the data. The JAGS code
  must not be in a data or model block.

- constants:

  An nlist object (or list that can be coerced to nlist) specifying the
  values of nodes in code. The values are included in the output
  dataset.

- parameters:

  An nlist object (or list that can be coerced to nlist) specifying the
  values of nodes in code. The values are not included in the output
  dataset.

- monitor:

  A character vector (or regular expression if a string) specifying the
  names of the nodes in code to include in the dataset. By default all
  nodes are included.

- stochastic:

  A logical scalar specifying whether to monitor deterministic and
  stochastic (NA), only deterministic (FALSE) or only stochastic nodes
  (TRUE).

- latent:

  A logical scalar specifying whether to monitor observed and latent
  (NA), only latent (TRUE) or only observed nodes (FALSE).

- nsims:

  A whole number between 1 and 1,000,000 specifying the number of data
  sets to simulate. By default 1 data set is simulated.

- save:

  A flag specifying whether to return the data sets as an `nlists`
  object or save in `path`. If `save = NA` the datasets are returned as
  an `nlists` object and saved in `path`.

- path:

  A string specifying the path to the directory to save the data sets
  in.

- exists:

  A flag specifying whether the `path` directory should already exist
  (if `exists = NA` it doesn't matter).

- rdists:

  A character vector specifying the R functions to recognize as
  stochastic.

- ask:

  A flag specifying whether to ask before deleting sims compatible
  files.

- silent:

  A flag specifying whether to suppress warnings.

## Value

By default an
[`nlist::nlists_object()`](https://rdrr.io/pkg/nlist/man/nlists.html) of
the simulated data. Otherwise if `path` is defined saves the datasets as
individual `.rds` files and returns TRUE.

## Details

JAGS code is identified by the presence of '~' indicating a stochastic
variable node. Otherwise code is assumed to be R code and stochastic
variable nodes are those where assignment is immediately succeeded by a
call to one of the functions named in `rdists`.

Both constants and parameters must be `[nlist::nlist_object]s` (or lists
that can be coerced to such) . The only difference between constants and
parameters is that the values in constants are appended to the output
data while the values in parameters are not. Neither constants or
parameters can include missing values nor can they have elements with
the same name. Elements which are not in code are dropped with a warning
(unless `silent = TRUE` in which case the warning is suppressed).

Each set of simulated data set is written as a separate .rds file. The
files are labelled `data0000001.rds`, `data0000002.rds`,
`data0000003.rds` etc. The argument values are saved in the hidden file
`.sims.rds`.

sims compatible files are those matching the regular expression
`^((data\\\\d\{7,7\})|([.]sims))[.]rds$`.

Parallelization is implemented using the future package.

## See also

[`sims_rdists()`](https://poissonconsulting.github.io/sims/reference/sims_rdists.md)

## Examples

``` r
set.seed(101)
sims_simulate("a <- runif(1)", path = tempdir(), exists = NA, ask = FALSE)
#> $a
#> [1] 0.6373621
#> 
#> an nlists object of an nlist object with 1 numeric element
```
