#' Check Simulated Data
#' 
#' Checks that \code{dir} includes an 'argsims.rds' file and 
#' that the number and names of the data files are consistent with the 
#' number of simulations.
#'
#' @param dir A string of the name of the directory with the simulated data.
#' @param path A string of the path to \code{dir}.
#'
#' @return An invisible list of the values in 'argsims.rds'.
#' @export
sims_check <- function(dir = "sims", path = ".") {
  check_string(dir)
  check_string(path)
  
  path_dir <- file.path(path, dir)
  if(!dir.exists(path_dir)) err("directory '", path_dir, "' must already exist")
  
  if(!file.exists(file.path(path_dir, "argsims.rds")))
    err("directory '", path_dir, "' must contain 'argsims.rds'")
  
  argsims.rds <- readRDS(file.path(path_dir, "argsims.rds"))
  
  check_scalar(argsims.rds$code, "")
  check_inherits(argsims.rds$constants, "nlist")
  check_inherits(argsims.rds$parameters, "nlist")
  check_scalar(argsims.rds$monitor, "")
  check_scalar(argsims.rds$nsims, c(1L, 1000000L))
  check_scalar(argsims.rds$seed, c(0L, .max_integer))

  nsims <- argsims.rds$nsims
  
  files <- sims_files(path_dir, args = FALSE)
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
