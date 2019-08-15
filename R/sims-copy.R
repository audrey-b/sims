#' Copy Simulated Datasets
#' 
#' @param path_from A string of the path to the directory containing the simulated datasets.
#' @param path_to A string of the path to the directory to copy the simulated dataset to.
#' @param exists A flag specifying whether \code{path_to} should already exist.
#' If \code{exists = NA} it doesn't matter. If the directory already exists it is 
#' overwritten if \code{exists = TRUE} or \code{exists = NA} otherwise an
#' error is thrown.
#' @return A character vector of the names of the files copied.
#' @export
sims_copy <- function(path_from = "sims", path_to = paste0(path_from, "_copy"), 
                      exists = FALSE) {
  check_string(path_to)
  check_string(path_from)
  check_flag(exists)
  sims_check(path_from)

  create_path(path_to, exists = exists)
  files <- data_files(path_from)
  file.copy(file.path(path_from, c(".sims.rds", files)), to = path_to)
  files
}
