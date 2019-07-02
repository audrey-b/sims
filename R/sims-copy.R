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
#' @return A string of the path to the new directory, ie \code{file.path(path_to, dir_to)}.
#' @export
#' 
sims_copy <- function(dir_from = "sims", path_from = ".", 
                      dir_to = paste0(dir_from, "_copy"), path_to = path_from,
                      exists = FALSE) {
  check_string(dir_to)
  check_string(path_to)
  check_string(dir_from)
  check_string(path_from)
  check_flag(exists)

  path_dir_from <- file.path(path_from, dir_from)
  path_dir_to <- file.path(path_to, dir_to)
  if(!dir.exists(path_dir_from))
      err("directory '", path_dir_from, "' must already exist")
  path_dir_to_exists <- dir.exists(path_dir_to)
  if(isFALSE(exists) && path_dir_to_exists)
      err("directory '", path_dir_to, "' must not already exist")
  if(isTRUE(exists) && !path_dir_to_exists)
      err("directory '", path_dir_to, "' must already exist")
  if(path_dir_to_exists) unlink(path_dir_to, recursive = TRUE)
  dir.create(path_dir_to, recursive = TRUE)
  
  files <- list.files(path_dir_from, pattern = "^((argsims)|(data\\d{7,7})).rds$")
  files
}
