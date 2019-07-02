#' Simulate Datasets
#' 
#' Simulates datasets using JAGS code. The user can specify whether to
#' return the datasets as an nlists object (each element is an nlist object
#' of a dataset) and/or write the datasets to a directory as individual \code{.rds}
#' files.
#'
#' Both constants and parameters must be nlist objects or 
#' uniquely named lists of numeric vectors, matrices and arrays that can be
#' coerced to nlist objects.
#' The only difference between constants and parameters is that the values in 
#' constants are appended to the output data while the values in parameters 
#' are not.
#' Neither constants or parameters can include missing values nor can they 
#' have elements with the same name.
#' Elements which are not in code are dropped with a warning.
#' 
#' Each set of simulated data set is written as a separate .rds file. 
#' The files are labelled \code{data0000001.rds}, \code{data0000002.rds},
#' \code{data0000003.rds} etc.
#'
#' @param code A string of the JAGS code to generate the data.
#' The code must not be in a data or model block.
#' @param constants An nlist specifying the values of nodes in code. 
#' The values are included in the output data.
#' @param parameters An nlist specifying the values of nodes in code. 
#' The values are not included in the output data.
#' @param monitor A character vector (or regular expression if a string) 
#' specifying the names of the stochastic nodes in code to include in the data.
#' By default all stochastic nodes are included.
#' @param nsims An integer between 1 and 1,000,000 specifying 
#' the number of data sets to simulate. By default 100 data sets are simulated.
#' @param seed A positive integer specifying the random seed to use for 
#' simulating the data. By default it is also used to name the directory 
#' in which the data are saved if \code{write = TRUE}.
#' @param write A flag specifying whether to write the nlists object to 
#' individual files in the (as opposed to returning them). If \code{write = NA}
#' then the nlists object is both written and returned. 
#' @param exists A flag specifying whether the directory should already exist.
#' If \code{exists = NA} it doesn't matter. If the directory already exists it is 
#' overwritten if \code{exists = TRUE} or \code{exists = NA} otherwise an
#' error is thrown.
#' @param dir If \code{write = TRUE} or \code{write = NA} 
#' a string specifying the name of the directory to save the data sets in.
#' By default the name is \code{paste0("sims", seed)}, 
#' ie if \code{seed = 10}, \code{dir = "sims10"}.
#' @param path A string specifying the file path to \code{dir}.
#' @param silent A flag specifying whether to suppress warnings.
#'
#' @return If \code{write != TRUE} an \code{\link[nlist]{nlists}} 
#' object where each element represents a simulated data set.
#' Otherwise the full path to the directory, ie, \code{file.path(path, dir)}.
#' @export
#' @examples
#' set.seed(101)
#' sims_nlist("a ~ dunif(0, 1)")
sims_nlist <- function(code, 
                       constants = nlist::nlist(), 
                       parameters = nlist::nlist(), 
                       monitor = ".*",
                       nsims = getOption("sims.nsims", 100L), 
                       seed = sims_rcount(),
                       write = FALSE,
                       exists = FALSE,
                       dir = paste0("sims", seed),
                       path = ".",
                       silent = FALSE) {
  check_string(code)
  check_nlist(constants, nas = FALSE, class = NA)
  check_nlist(parameters, nas = FALSE, class = NA)
  check_vector(monitor, "", length = TRUE)
  check_int(nsims, coerce = TRUE)
  check_scalar(seed, c(1L, .max_integer))
  check_scalar(write, c(TRUE, NA))
  check_scalar(exists, c(TRUE, NA))
  check_string(path)
  check_string(dir)
  check_flag(silent)
  
  nsims <- as.integer(nsims)
  check_scalar(nsims, c(1L, 1000000L))
  
  constants <- as.nlist(constants)
  parameters <- as.nlist(parameters)
  
  check_variable_nodes(code, constants)
  check_variable_nodes(code, parameters)
  
  path_dir <- create_path_dir(path, dir, write, exists)
  
  monitor <- set_monitor(monitor, code, silent = silent)
  code <- prepare_code(code)
  
  generate_datasets(code, constants, parameters, 
                    monitor = monitor, 
                    nsims = nsims,
                    seed = seed,
                    write = write,
                    path_dir = path_dir)
}
