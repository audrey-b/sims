#' Simulate Datasets
#' 
#' Simulates datasets using JAGS code. By defaults 
#' return the datasets as an \code{\link[nlist]{nlists_object}}.
#' If \code{path} is provided then the datasets are written to the directory 
#' as individual \code{.rds} files.
#'
#' Both constants and parameters must be \code{\link[nlist]{nlist_object}s} or 
#' uniquely named lists of numeric vectors, matrices and arrays that can be
#' coerced to nlist objects.
#' The only difference between constants and parameters is that the values in 
#' constants are appended to the output data while the values in parameters 
#' are not.
#' Neither constants or parameters can include missing values nor can they 
#' have elements with the same name.
#' Elements which are not in code are dropped with a warning 
#' (unless \code{silent = TRUE} in which case the warning is suppressed).
#' 
#' Each set of simulated data set is written as a separate .rds file. 
#' The files are labelled \code{data0000001.rds}, \code{data0000002.rds},
#' \code{data0000003.rds} etc.
#'
#' @param code A string of the JAGS code to generate the data.
#' The code must not be in a data or model block.
#' @param constants An nlist object specifying the values of nodes in code. 
#' The values are included in the output data.
#' @param parameters An nlist object specifying the values of nodes in code. 
#' The values are not included in the output data.
#' @param monitor A character vector (or regular expression if a string) 
#' specifying the names of the stochastic nodes in code to include in the data.
#' By default all stochastic nodes are included.
#' @param nsims An integer between 1 and 1,000,000 specifying 
#' the number of data sets to simulate. By default 100 data sets are simulated.
#' @param seed A whole number specifying the seed to use for 
#' simulating the data (or NULL).
#' @param parallel A flag specifying whether to generate the datasets in parallel. 
#' @param path A string specifying the path to the directory to save the data sets in.
#' By default \code{path = NULL } the data sets are not saved but are returned 
#' as an nlists object.
#' @param exists A flag specifying whether the directory should already exist.
#' If \code{exists = NA} it doesn't matter. If the directory already exists it is 
#' overwritten if \code{exists = TRUE} or \code{exists = NA} otherwise an
#' error is thrown.
#' @param silent A flag specifying whether to suppress warnings.
#'
#' @return By default an \code{\link[nlist]{nlists_object}} of the simulated data.
#' Otherwise if \code{path} is defined the simulated data argument values.
#' @export
#' @examples
#' set.seed(101)
#' sims_simulate("a ~ dunif(0, 1)", path = tempdir(), exists = NA)
sims_simulate <- function(code, 
                          constants = nlist::nlist(), 
                          parameters = nlist::nlist(), 
                          monitor = ".*",
                          nsims = getOption("sims.nsims", 100L), 
                          seed = NULL,
                          parallel = FALSE,
                          path = NULL,
                          exists = FALSE,
                          silent = FALSE) {
  check_string(code)
  check_nlist(constants, nas = FALSE, class = NA)
  check_nlist(parameters, nas = FALSE, class = NA)
  check_vector(monitor, "", length = TRUE)
  check_int(nsims, coerce = TRUE)
  if(!is.null(seed)) chk_whole_number(seed)
  check_flag(parallel)
  if(!is.null(path)) check_string(path)
  check_scalar(exists, c(TRUE, NA))
  check_flag(silent)
  
  if(!isFALSE(parallel)) .NotYetUsed("parallel")
  
  nsims <- as.integer(nsims)
  check_scalar(nsims, c(1L, 1000000L))
  
  constants <- as.nlist(constants)
  parameters <- as.nlist(parameters)
  
  check_variable_nodes(code, constants)
  check_variable_nodes(code, parameters)
  
  if(!is.null(path)) create_path(path, exists)
  
  if(is.null(seed))
    seed <- rinteger()
  seed <- as.integer(seed)
  
  monitor <- set_monitor(monitor, code, silent = silent)
  code <- prepare_code(code)
  
  generate_datasets(code, constants, parameters, 
                    monitor = monitor, 
                    nsims = nsims,
                    seed = seed,
                    path = path)
}
