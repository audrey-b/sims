#' Simulate Datasets
#'
#' Simulates datasets using JAGS or R code. By default
#' returns the datasets as an [nlist::nlists_object()].
#' If `path` is provided then the datasets are written to the directory
#' as individual `.rds` files.
#'
#' JAGS code is identified by the presence of '~' indicating a
#' stochastic variable node.
#' Otherwise code is assumed to be R code and stochastic variable nodes
#' are those where assignment is immediately succeeded
#' by a call to one of the functions named in `rdists`.
#'
#' Both constants and parameters must be `[nlist::nlist_object]s`
#' (or lists that can be coerced to such) .
#' The only difference between constants and parameters is that the values in
#' constants are appended to the output data while the values in parameters
#' are not.
#' Neither constants or parameters can include missing values nor can they
#' have elements with the same name.
#' Elements which are not in code are dropped with a warning
#' (unless `silent = TRUE` in which case the warning is suppressed).
#'
#' Each set of simulated data set is written as a separate .rds file.
#' The files are labelled `data0000001.rds`, `data0000002.rds`,
#' `data0000003.rds` etc.
#' The argument values are saved in the hidden file `.sims.rds`.
#'
#' sims compatible files are those matching the regular expression
#' `^((data\\\\d\{7,7\})|([.]sims))[.]rds$`.
#'
#' Parallelization is implemented using the future package.
#'
#' @inheritParams params
#' @param path A string specifying the path to the directory to save
#' the data sets in.
#' @return By default an [nlist::nlists_object()] of the simulated data.
#' Otherwise if `path` is defined saves the datasets as individual `.rds`
#' files and returns TRUE.
#' @seealso [sims_rdists()]
#' @export
#' @examples
#' set.seed(101)
#' sims_simulate("a <- runif(1)", path = tempdir(), exists = NA, ask = FALSE)
sims_simulate <- function(code,
                          constants = nlist::nlist(),
                          parameters = nlist::nlist(),
                          monitor = ".*",
                          stochastic = NA,
                          latent = NA,
                          nsims = 1,
                          save = FALSE,
                          path = ".",
                          exists = FALSE,
                          rdists = sims_rdists(),
                          ask = getOption("sims.ask", TRUE),
                          silent = FALSE) {
  if (is.list(constants) && !is_nlist(constants)) class(constants) <- "nlist"
  if (is.list(parameters) && !is_nlist(parameters)) class(parameters) <- "nlist"

  chk_string(code)
  chk_nlist(constants)
  chk_not_any_na(constants)
  chk_nlist(parameters)
  chk_not_any_na(parameters)
  chk_s3_class(monitor, "character")
  chk_gt(length(monitor))
  chk_lgl(stochastic)
  chk_lgl(latent)
  chk_whole_number(nsims)
  chk_range(nsims, c(1, 1000000))
  chk_lgl(save)
  chk_string(path)
  chk_flag(ask)
  chk_lgl(exists)
  chk_s3_class(rdists, "character")
  chk_not_any_na(rdists)
  chk_flag(silent)

  nsims <- as.integer(nsims)

  code <- prepare_code(code)

  check_variable_nodes(code, constants, rdists)
  check_variable_nodes(code, parameters, rdists)

  if (!isFALSE(save)) create_path(path, exists, ask, silent)

  monitor <- set_monitor(monitor, code, stochastic, latent,
    rdists = rdists, silent = silent
  )

  generate_datasets(code, constants, parameters,
    monitor = monitor,
    nsims = nsims, save = save,
    path = path
  )
}
