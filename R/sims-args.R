#' Simulated Data Argument Values
#' 
#' Gets the simulated data argument values in the '.sims_info.rds' file.
#'
#' @param path A string of the path to the directory with the simulated data.
#'
#' @return A named list of the values in \code{file.path(path, '.sims_info.rds')}.
#' @export
#' @examples 
#' set.seed(10)
#' sims_simulate("a ~ dunif(0,1)", path = tempdir(), exists = NA)
#' sims_info(tempdir())
sims_info <- function(path) {
  check_string(path)
  
  if(!dir.exists(path)) err("directory '", path, "' must already exist")
  
  if(!file.exists(file.path(path, .argsims)))
    err("directory '", path, "' must contain '", .argsims, "'")
  
  readRDS(file.path(path, .argsims))
}
