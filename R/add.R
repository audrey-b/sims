#' Add Simulated Datasets
#'
#' @inheritParams sims_simulate
#' @param path A string specifying the path to the directory to add the data sets to.
#' @param nsims A count of the number of additional datasets to generate.
#' @return A character vector of the names of the files created
#' (and in the case of argsism, created).
#' @export
sims_add <- function(path = ".",
                     nsims = 1,
                     progress = FALSE,
                     options = furrr::future_options()) {
  
  chk_whole_number(nsims)
  chk_range(nsims, c(1, 1000000))
  chk_flag(progress)
  chk_s3_class(options, "future_options")
  chk_false(options$seed)
  
  nsims <- as.integer(nsims)
  
  argsims <- sims_check(path)
  argsims$nsims <- argsims$nsims + nsims
  
  if(argsims$nsims > 1000000L)
    err("Adding the simulations would result in more than 1,000,000 datasets.")
  
  sims <- (argsims$nsims - nsims + 1L):argsims$nsims
  
  seed <- get_random_seed()
  on.exit(set_random_seed(seed, advance = TRUE))
  
  set_random_seed(argsims$seed)
  
  options$seed <- get_seed_streams(argsims$nsims)[sims]
  
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
                       monitor = argsims$monitor, save = TRUE,
                       path = path, 
                       .progress = progress, .options = options)
  data_files(path)[sims]
}
