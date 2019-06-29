#' Simulate nlists Object
#'
#' Both constants and parameters are nlist objects or 
#' uniquely named lists of numeric vectors, matrices and arrays that can be
#' coerced to nlist objects.
#' The only difference between constants and parameters is that the values in 
#' constants are appended to the output data while the values in parameters are not.
#' Neither constants or parameters can include missing values nor can they 
#' have elements with the same name.
#' Elements which are not in code are dropped with a warning.
#'
#' @param code A string of the JAGS code to generate the data.
#' The code must not be in a data or model block.
#' @param constants An nlist specifying values in code that are output in 
#' the data. The values are included in the output data.
#' @param parameters An nlist specifying values in code that are not output
#' in the data. The values are not included in the output data.
#' @param monitor A character vector (or regular expression if a string) 
#' specifying the names of the stochastic nodes in code to include in the data.
#' By default all stochastic nodes are included.
#' @param nsims A positive integer between 1 and 100,000 specifying 
#' the number of data sets to simulate. By default 100 data sets are simulated.
#' @param silent A flag specifying whether to suppress warnings.
#'
#' @return An \code{\link[nlist]{nlists}} object where each element represents
#' a simulated data set.
#' @export
#' @examples
#' set.seed(101)
#' sims_nlist("a ~ dunif(0, 1)")
sims_nlist <- function(code, 
                       constants = nlist::nlist(), 
                       parameters = nlist::nlist(), 
                       monitor = ".*",
                       nsims = getOption("sims.nsims", 100L), 
                       silent = FALSE) {
  check_string(code)
  check_nlist(constants, nas = FALSE, class = NA)
  check_nlist(parameters, nas = FALSE, class = NA)
  check_vector(monitor, "", length = TRUE)
  check_int(nsims, coerce = TRUE)
  check_flag(silent)

  constants <- as.nlist(constants)
  parameters <- as.nlist(parameters)
  
  nsims <- as.integer(nsims)
  check_scalar(nsims, c(1L, 100000L))

  data <- c(constants, parameters)

  check_variable_nodes(code, constants)
  check_variable_nodes(code, parameters)
  
  monitor <- set_monitor(monitor, code, silent = silent)
  data <- generate_data(code, data, monitor, nsims)
  # need to add constants
  data
}
