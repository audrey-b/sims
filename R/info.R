#' Simulated Data Argument Values
#'
#' Gets the simulated data argument values in the '.sims.rds' file.
#'
#' @inheritParams params
#' @return A named list of the values in `file.path(path, '.sims.rds')`.
#' @export
#' @examples
#' set.seed(10)
#' sims_simulate("a <- runif(1)", path = tempdir(), exists = NA, ask = FALSE)
#' sims_info(tempdir())
sims_info <- function(path = ".") {
  chk_string(path)
  chk_dir(path)

  if (!file.exists(file.path(path, ".sims.rds"))) {
    err("Directory '", path, "' must contain '.sims.rds'.")
  }

  readRDS(file.path(path, ".sims.rds"))
}
