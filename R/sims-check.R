#' Check Simulated Data
#' 
#' Checks that the number and names of the data files are consistent with the 
#' number of simulations in the '.argsims.rds' file.
#'
#' @param path A string of the path to the directory with the simulated data.
#'
#' @return A list of the values in \code{file.path(path, '.argsims.rds')}.
#' @export
sims_check <- function(path = "sims") {
  check_string(path)
  
  if(!dir.exists(path)) err("directory '", path, "' must already exist")
  
  if(!file.exists(file.path(path, .argsims)))
    err("directory '", path, "' must contain '", .argsims, "'")
  
  argsims <- readRDS(file.path(path, .argsims))
  
  check_scalar(argsims$code, "")
  check_inherits(argsims$constants, "nlist")
  check_inherits(argsims$parameters, "nlist")
  check_scalar(argsims$monitor, "")
  check_scalar(argsims$nsims, c(1L, 1000000L))
  check_scalar(argsims$seed, c(0L, .max_integer))

  nsims <- argsims$nsims
  
  files <- data_files(path)
  if(!identical(length(files), nsims)) {
    err("number of data files (", length(files), 
        ") does not match number of simulations (", nsims, ")")
  }
  if(!identical(files, data_file_name(1:nsims))) {
    err("data file names are not consistent with",
        "the number of simulations (", nsims, ")")
  }
  argsims
}
