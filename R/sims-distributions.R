#' Sims Distributions
#' 
#' Gets names of the random variate generating R functions recognized by sims 
#' as producing stochastic variable nodes.
#' 
#' By default the functions are the random variate generating functions
#' listed in \code{\link{Distributions}}.
#'
#' @return A character vector of the names of random variate generating R functions.
#' @export
#'
#' @examples
#' sims_distributions()
sims_distributions <- function() {
  getOption("sims.distributions", .sims_distributions)
}

#' Sims Add Distributions
#' 
#' @param x A character vector of the random variate generating R functions to add.
#' @return A character vector of the names of .
#' @export
#'
#' @examples
#' print(sims_add_distributions("llog"))
sims_add_distributions <- function(x = character(0)) {
  chk_is(x, "character")
  chk_no_missing(x)
  
  dists <- sims_distributions()
  dists <- as.character(sort(unique(c(dists, x))))
  options(sims.distributions = dists)
}
