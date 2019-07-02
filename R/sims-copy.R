#' Copy Simulated Datasets
#'
#' @param dir_from A string of the name of the directory containing the simulated datasets.
#' @param path_from A string of the path to \code{dir_from}.
#' @param dir_to A string of the name of the directory to copy the simulated dataset to.
#' @param path_to A string of the path to \code{dir_to}.
#' @param exists A flag specifying whether \code{dir_to} should already exist.
#' If \code{exists = NA} it doesn't matter. If the directory already exists it is 
#' overwritten if \code{exists = TRUE} or \code{exists = NA} otherwise an
#' error is thrown.
#' @return An invisible character vector of the names of the files copied.
#' @export
sims_copy <- function(dir_from = "sims", path_from = ".", 
                      dir_to = paste0(dir_from, "_copy"), path_to = path_from,
                      exists = FALSE) {
  check_string(dir_to)
  check_string(path_to)
  check_string(dir_from)
  check_string(path_from)
  check_flag(exists)

  path_dir_from <- file.path(dir_from, path_from)
  path_dir_to <- create_path_dir(dir = dir_to, path = path_to, 
                    exists = exists, write = TRUE)
  
  sims_check(dir_from, path_from)
  files <- sims_files(path_dir_from)
  files 
#  file.copy(file, to)
#  invisible(files)
}
