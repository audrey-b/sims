#' Add Simulated Datasets
#'
#' @param path A string specifying the path to the directory to
#' add the data sets to.
#' @param nsims A count of the number of additional datasets to generate.
#' @return A character vector of the names of the files created.
#' @export
sims_add <- function(path = ".",
                     nsims = 1) {
  chk_whole_number(nsims)
  chk_range(nsims, c(1, 1000000))

  nsims <- as.integer(nsims)

  argsims <- sims_check(path)
  argsims$nsims <- argsims$nsims + nsims

  if (argsims$nsims > 1000000L) {
    err("Adding the simulations would result in more than 1,000,000 datasets.")
  }

  sims <- (argsims$nsims - nsims + 1L):argsims$nsims

  seed <- get_random_seed()
  on.exit(set_random_seed(seed, advance = TRUE))

  set_random_seed(argsims$seed)

  saveRDS(argsims, file.path(path, ".sims.rds"))

  code <- argsims$code
  if (is_jags_code(code)) {
    if(!requireNamespace("rjags", quietly = TRUE))
      err("Package 'rjags' must be installed to simulate data using JAGS code.")
    is_jags <- TRUE
  } else {
    is_jags <- FALSE
    code <- parse(text = code)
  }

  if(requireNamespace("progressr", quietly = TRUE)) {
    p <- progressr::progressor(along = sims)
  } else 
    p <- NULL
  
  nlists <- future_lapply(sims, generate_dataset,
    is_jags = is_jags,
    code = code,
    constants = argsims$constants,
    parameters = argsims$parameters,
    monitor = argsims$monitor, save = TRUE,
    path = path, p = p,
    future.seed = get_seed_streams(argsims$nsims)[sims]
  )
  data_files(path)[sims]
}
