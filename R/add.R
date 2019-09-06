#' Add Simulated Datasets
#'
#' @inheritParams sims_simulate
#' @param path A string specifying the path to the directory to add the data sets to.
#' @param nsims A count of the number of additional datasets to generate.
#' By default 100 datasets are added.
#' @return A character vector of the names of the files created 
#' (and in the case of argsism, created).
#' @export
sims_add <- function(path, nsims = getOption("sims.nsims", 100L),
                     progress = FALSE,
                     options = furrr::future_options()) {
  
  if(is_chk_on()) {
    chk_whole_number(nsims); chk_range(nsims, c(1, 1000000))
    chk_flag(progress)
    chk_is(options, "future_options")
  }
  
  nsims <- as.integer(nsims)
  
  argsims <- sims_check(path)
  argsims$nsims <- argsims$nsims + nsims
  
  if(argsims$nsims > 1000000L)
    err("Adding the simulations would result in more than 1,000,000 datasets.")
  
  sims <- (argsims$nsims - nsims + 1L):argsims$nsims
  
  saveRDS(argsims, file.path(path, ".sims.rds"))
  
  code <- argsims$code
  if(is_jags_code(code)) {
    is_jags <- TRUE
  } else {
    is_jags <- FALSE
    code <- parse(text = code)
  }
  
  nlists <- future_map(sims, generate_dataset,  is_jags = is_jags, 
                       code = code, 
                       constants = argsims$constants, 
                       parameters = argsims$parameters, 
                       monitor = argsims$monitor, 
                       path = path, seed = argsims$seed,
                       .progress = progress, .options = options)
  data_files(path)[sims]
}
