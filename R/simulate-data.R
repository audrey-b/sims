#' Simulate Data
#'
#' @param code A string of the JAGS code to simulate the data.
#' The code must not be in a data or model block.
#' @param fixed A uniquely named list of numeric vectors, matrices and arrays
#'  specifying known values. It cannot include missing values or variable nodes.
#' @param monitor A regular expression that specifying the stochastic nodes to simulate.
#' Monitor must match at least one stochastic node.
#'
#' @return A uniquely named list of numeric vectors, matrices and arrays of the 
#' simulated data values.
#' @export
bsm_simulate_data <- function(code, fixed, monitor = ".*") {
  check_string(code)
  check_data_list(fixed)
  check_string(monitor)
  check_variable_nodes(code, fixed)

  monitor <- set_monitor(monitor, code)
  code <- prepare_code(code)
  data <- generate_data(code, fixed, monitor)
  data
}
