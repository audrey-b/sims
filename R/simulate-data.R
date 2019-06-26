#' Simulate Data
#'
#' @param code A string of the JAGS code to simulate the data.
#' The code must not be in a data or model block.
#' @param constants A uniquely named list of numeric vectors, matrices and arrays
#'  specifying constant values. It cannot include missing values or variable nodes.
#' @param parameters A uniquely named list of numeric vectors, matrices and arrays
#'  specifying parameter values. It cannot include missing values or variable nodes.
#' @param monitor A regular expression that specifying the stochastic nodes to simulate.
#' Monitor must match at least one stochastic node.
#'
#' @return A uniquely named list of numeric vectors, matrices and arrays of the 
#' simulated data values.
#' @export
bsm_simulate_data <- function(code, constants, parameters, monitor = ".*") {
  check_string(code)
  check_data_list(constants)
  check_data_list(parameters)
  check_string(monitor)
  check_distinct_names(constants = constants, parameters = parameters)
  check_variable_nodes(code, constants)
  check_variable_nodes(code, parameters)
  
  monitor <- set_monitor(monitor, code)
  code <- prepare_code(code)
  variables <- c(constants, parameters)
  data <- generate_data(code, variables, monitor)
  data
}
