#' Simulate Data
#'
#' The jags codes should not be in a block.
#' The constant and parameter arguments cannot include missing values.
#' 
#' @param jags_code A string of the jags code to simulate the data.
#' @param constants A uniquely named list of numeric vectors, matrices and arrays
#'  specifying constant values.
#' @param parameters A uniquely named list of numeric vectors, matrices and arrays
#'  specifying parameter values.
#' @param monitor A regular expression specifying the data to
#'
#' @return A uniquely named list of numeric vectors, matrices and arrays of the 
#' simulated data values.
#' @export
bsm_simulate_data <- function(jags_code, constants, parameters, monitor = ".*") {
  check_string(jags_code)
  check_data_list(constants)
  check_data_list(parameters)
  check_string(monitor)
  check_distinct_names(constants = constants, parameters = parameters)
  
}
