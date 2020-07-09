#' Simulated Data Files
#'
#' Gets the names of the simulated data files.
#'
#' @param path A string of the path to the directory with the simulated data.
#'
#' @return A character vector of the names of the simulated data files.
#' @export
#' @examples
#' set.seed(10)
#' sims_simulate("a ~ dunif(0,1)",
#'   nsims = 10L, path = tempdir(),
#'   exists = NA, ask = FALSE
#' )
#' sims_data_files(tempdir())
sims_data_files <- function(path = ".") {
  sims_info(path)
  data_files(path)
}
