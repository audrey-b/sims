#' Simulate Data
#'
#' @param code A string of the JAGS code to simulate the data.
#' The code must not be in a data or model block.
#' @param fixed A uniquely named list of numeric vectors, matrices and arrays
#'  specifying known non-missing values. 
#'  The names cannot match variable (stochastic or deterministic) nodes in code.
#' @param monitor A character vector specifying the names of the stochastic nodes 
#' to simulate or if a string (length one character vector) a regular expression 
#' that must match at least one stochastic node in code. 
#' @param nsamples A positive integer of the number of samples to simulate.
#' @param silent A flag specifying whether to suppress messages and warnings.
#'
#' @return The simulated data values in the form of a single chain 
#' \code{\link[mcmcr]{mcmcr}} object where each iteration represents one sample.
#' @export
#' @examples
#' set.seed(101)
#' bsm_simulate_data("a ~ dunif(0, 1)", nsamples = 1L)
bsm_simulate_data <- function(code, fixed = named_list(), monitor = ".*",
                              nsamples = 100L, silent = FALSE) {
  check_string(code)
  check_data_list(fixed)
  check_vector(monitor, "", length = TRUE)
  check_variable_nodes(code, fixed)
  nsamples <- check_int(nsamples, coerce = TRUE)
  check_scalar(nsamples, c(1L, chk_max_int()))
  check_flag(silent)

  monitor <- set_monitor(monitor, code, silent = silent)
  code <- prepare_code(code)
  data <- generate_data(code, fixed, monitor, nsamples)
  data
}
