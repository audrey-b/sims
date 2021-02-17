#' Parameters for sims functions
#'
#' Descriptions of the parameters for the sims functions.
#'
#' @keywords internal
#' @name params
#' @param path A string of the path to the directory with the simulated data.
#' @param path_from A string of the path to the directory containing
#' the simulated datasets.
#' @param path_to A string of the path to the directory to copy
#' the simulated dataset to.
#' @param code A string of the JAGS or R code to generate the data.
#' The JAGS code must not be in a data or model block.
#' @param constants An nlist object (or list that can be coerced to nlist)
#' specifying the values of nodes in code.
#' The values are included in the output dataset.
#' @param parameters An nlist object (or list that can be coerced to nlist)
#' specifying the values of nodes in code.
#' The values are not included in the output dataset.
#' @param monitor A character vector (or regular expression if a string)
#' specifying the names of the nodes in code to include in the dataset.
#' By default all nodes are included.
#' @param stochastic A logical scalar specifying whether to monitor
#' deterministic and stochastic (NA), only deterministic (FALSE)
#' or only stochastic nodes (TRUE).
#' @param latent A logical scalar specifying whether to monitor
#' observed and latent (NA), only latent (TRUE)
#' or only observed nodes (FALSE).
#' @param nsims A whole number between 1 and 1,000,000 specifying
#' the number of data sets to simulate. By default 1 data set is simulated.
#' @param save A flag specifying whether to return the data sets as
#' an `nlists` object or save in `path`. If `save = NA`
#' the datasets are returned as an `nlists` object and saved in `path`.
#' @param exists A flag specifying whether the `path` directory should
#' already exist (if `exists = NA` it doesn't matter).
#' @param rdists A character vector specifying the R functions to recognize
#' as stochastic.
#' @param ask A flag specifying whether to ask before deleting sims
#' compatible files.
#' @param silent A flag specifying whether to suppress warnings.
NULL