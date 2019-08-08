#' Add Simulated Datasets
#'
#' @param path A string specifying the path to the directory to add the data sets to.
#' @param nsims A count of the number of additional datasets to generate.
#' By default 100 datasets are added.
#' @return A character vector of the names of the files created 
#' (and in the case of argsism, created).
#' @export
sims_add <- function(path, nsims = getOption("sims.nsims", 100L)) {
  check_int(nsims, coerce = TRUE)
  nsims <- as.integer(nsims)
  check_scalar(nsims, c(1L, 1000000L))
  
  argsims <- sims_check(path)
  argsims$nsims <- argsims$nsims + nsims
  
  if(argsims$nsims > 1000000L)
    err("adding the simulations would result in more than 1,000,000 datasets")
  
  sims <- (argsims$nsims - nsims + 1L):argsims$nsims

  saveRDS(argsims, file.path(path, .argsims))
  
  nlists <- lapply(sims, generate_dataset,  code = argsims$code, 
                                   constants = argsims$constants, 
                                   parameters = argsims$parameters, 
                                   monitor = argsims$monitor, 
                                   path = path, seed = argsims$seed)
  data_files(path)[sims]
}
