# Copy Simulated Datasets

Copy Simulated Datasets

## Usage

``` r
sims_copy(
  path_from = ".",
  path_to = paste0(path_from, "_copy"),
  exists = FALSE,
  ask = getOption("sims.ask", TRUE),
  silent = FALSE
)
```

## Arguments

- path_from:

  A string of the path to the directory containing the simulated
  datasets.

- path_to:

  A string of the path to the directory to copy the simulated dataset
  to.

- exists:

  A flag specifying whether `path_to` should already exist. If
  `exists = NA` it doesn't matter. If the directory already exists sims
  compatible files are deleted if `exists = TRUE` or `exists = NA`
  otherwise an error is thrown.

- ask:

  A flag specifying whether to ask before deleting files.

- silent:

  A flag specifying whether to suppress warnings.

## Value

A character vector of the names of the files copied.
