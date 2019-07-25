#' Check Simulated Data
#' 
#' Checks that the number and names of the data files are consistent with the 
#' number of simulations in the '.sims_args.rds' file.
#'
#' @param path A string of the path to the directory with the simulated data.
#'
#' @return A list of the values in \code{file.path(path, '.sims_args.rds')}.
#' @export
sims_check <- function(path = "sims") {
  sims_args <- sims_args(path)

  check_scalar(sims_args$code, "")
  check_inherits(sims_args$constants, "nlist")
  check_inherits(sims_args$parameters, "nlist")
  check_scalar(sims_args$monitor, "")
  check_scalar(sims_args$nsims, c(1L, 1000000L))
  check_scalar(sims_args$seed, c(0L, .max_integer))

  nsims <- sims_args$nsims
  
  files <- data_files(path)
  if(!identical(length(files), nsims)) {
    err("number of data files (", length(files), 
        ") does not match number of simulations (", nsims, ")")
  }
  if(!identical(files, data_file_name(1:nsims))) {
    err("data file names are not consistent with",
        "the number of simulations (", nsims, ")")
  }
  sims_args
}
