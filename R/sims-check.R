#' Check Simulated Data
#' 
#' Checks that \code{path} includes an 'argsims.rds' file and 
#' that the number and names of the data files are consistent with the 
#' number of simulations.
#'
#' @param path A string of the path to he directory with the simulated data.
#'
#' @return An invisible list of the values in \code{file.path(path, 'argsims.rds')}.
#' @export
sims_check <- function(path = "sims") {
  check_string(path)
  
  if(!dir.exists(path)) err("directory '", path, "' must already exist")
  
  if(!file.exists(file.path(path, "argsims.rds")))
    err("directory '", path, "' must contain 'argsims.rds'")
  
  argsims.rds <- readRDS(file.path(path, "argsims.rds"))
  
  check_scalar(argsims.rds$code, "")
  check_inherits(argsims.rds$constants, "nlist")
  check_inherits(argsims.rds$parameters, "nlist")
  check_scalar(argsims.rds$monitor, "")
  check_scalar(argsims.rds$nsims, c(1L, 1000000L))
  check_scalar(argsims.rds$seed, c(0L, .max_integer))

  nsims <- argsims.rds$nsims
  
  files <- sims_files(path, args = FALSE)
  if(!identical(length(files), nsims)) {
    err("number of data files (", length(files), 
        ") does not match number of simulations (", nsims, ")")
  }
  if(!identical(files, data_file_name(1:nsims))) {
    err("data file names are not consistent with",
        "the number of simulations (", nsims, ")")
  }
  invisible(argsims.rds)
}
