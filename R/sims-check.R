#' Check Simulated Data
#' 
#' Checks the simulated data argument values in the '.sims_args.rds' file.
#' 
#' The checks include whether number and names of the data files 
#' in the directory are consistent with the number of simulations.
#'
#' @param path A string of the path to the directory with the simulated data.
#'
#' @return An informative error or invisible list of the argument values.
#' @export
#' 
#' @examples
#' set.seed(10)
#' sims_simulate("a ~ dunif(0,1)", path = tempdir(), exists = NA)
#' print(sims_check(tempdir()))
sims_check <- function(path) {
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
  invisible(sims_args)
}
