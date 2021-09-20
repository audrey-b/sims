#' Simulated Data Files
#'
#' Gets the names of the simulated data files.
#'
#' @inheritParams params
#' @return A character vector of the names of the simulated data files.
#' @export
#' @examples
#' set.seed(10)
#' sims_simulate("a <- runif(1)",
#'   nsims = 10L, path = tempdir(),
#'   exists = NA, ask = FALSE
#' )
#' sims_data_files(tempdir())
sims_data_files <- function(path = ".") {
  sims_info(path)
  data_files(path)
}
