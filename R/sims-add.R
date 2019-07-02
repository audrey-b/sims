#' Add Simulated Datasets
#'
#' @param nsims A count of the number of additional datasets to generate.
#' By default 100 datasets are added.
#' @param path A string specifying the path to the directory to add the data sets to.
#' @return A character vector of the names of the files created 
#' (and in the case of argsism, created).
#' @export
sims_add <- function(nsims = getOption("sims.nsims", 100L), path = "sims") {
  check_int(nsims, coerce = TRUE)
  nsims <- as.integer(nsims)
  check_scalar(nsims, c(1L, 1000000L))
  
  argsims <- sims_check(path)

  argsims$nsims <- argsims$nsims + nsims
  
  if(argsims$nsims > 1000000L)
    err("adding the simulations would result in more than 1,000,000 datasets")
  
  set.seed(argsims$seed)
  seeds <- sims_rcount(argsims$nsims)
  
  sims <- (argsims$nsims - nsims + 1L):argsims$nsims
  seeds <- seeds[sims]
  
  saveRDS(argsims, file.path(path, "argsims.rds"))
  
  nlists <- mapply(FUN = generate_dataset, sims, seeds,  
                   MoreArgs = list(code = argsims$code, 
                                   constants = argsims$constants, 
                                   parameters = argsims$parameters, 
                                   monitor = argsims$monitor, 
                                   write = TRUE, path = path),
                   SIMPLIFY = FALSE)
  sims_files(path)[c(1L, sims + 1L)]
}
