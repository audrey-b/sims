#' Check Simulated Data
#'
#' Checks the simulated data argument values in the '.sims.rds' file.
#'
#' The checks include whether number and names of the data files
#' in the directory are consistent with the number of simulations.
#'
#' @inheritParams params
#' @return An informative error or invisible list of the argument values.
#' @export
#'
#' @examples
#' set.seed(10)
#' sims_simulate("a <- runif(1)",
#'   save = TRUE, path = tempdir(), exists = NA,
#'   ask = FALSE
#' )
#' (sims_check(tempdir()))
sims_check <- function(path = ".") {
  sims_info <- sims_info(path)

  chk_string(sims_info$code)
  chk_s3_class(sims_info$constants, "nlist")
  chk_s3_class(sims_info$parameters, "nlist")
  chk_string(sims_info$monitor)
  chk_whole_number(sims_info$nsims)
  chk_range(sims_info$nsims, c(1L, 1000000L))
  chk_s3_class(sims_info$seed, "integer")
  chk_gt(length(sims_info$seed))

  nsims <- sims_info$nsims

  files <- data_files(path)
  if (!identical(length(files), nsims)) {
    err(
      "Number of data files (", length(files),
      ") does not match number of simulations (", nsims, ")."
    )
  }
  if (!identical(files, data_file_name(1:nsims))) {
    err(
      "Data file names are not consistent with",
      " the number of simulations (", nsims, ")."
    )
  }
  invisible(sims_info)
}
