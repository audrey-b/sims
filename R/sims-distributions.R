#' Sims Distributions
#' 
#' Gets the names of the random variate generating R functions recognized by sims 
#' as producing stochastic variable nodes.
#' 
#' By default the functions are the random variate generating functions
#' listed in \code{\link{Distributions}}.
#'
#' @return A character vector of the names of random variate generating R functions.
#' @seealso \code{\link{sims_add_distributions}()} and  
#' \code{\link{sims_reset_distributions}()}
#' @export
#'
#' @examples
#' sims_distributions()
sims_distributions <- function() {
  getOption("sims.distributions", .sims_distributions)
}

#' Sims Add Distributions
#' 
#' Adds sims distributions.
#' 
#' @param x A character vector of the random variate generating R functions.
#' @return A invisible character vector of the names of the previous R distributions.
#' @seealso \code{\link{sims_distributions}()} and  
#' \code{\link{sims_reset_distributions}()}
#' @export
#'
#' @examples
#' print(sims_add_distributions("llog"))
sims_add_distributions <- function(x) {
  chk_is(x, "character")
  chk_no_missing(x)
  
  dists <- sims_distributions()
  x <- as.character(sort(unique(c(dists, x))))
  options(sims.distributions = x)
  invisible(dists)
}

#' Sims Reset Distributions
#'
#' Resets sims distributions.
#'   
#' @return A invisible character vector of the names of the previous R distributions.
#' @seealso \code{\link{sims_distributions}()} and  
#' \code{\link{sims_set_distributions}()}
#' @export
#'
#' @examples
#' print(sims_reset_distributions())
sims_reset_distributions <- function() {
  dists <- sims_distributions()
  options(sims.distributions = NULL)
  invisible(dists)
}

#' Sims Set Distributions
#'
#'  Sets sims distributions.
#'
#' @param x A character vector of the random variate generating R functions.   
#' @return A invisible character vector of the names of the previous R distributions.
#' @seealso \code{\link{sims_distributions}()} and  
#' \code{\link{sims_reset_distributions}()}
#' @export
#'
#' @examples
#' print(sims_set_distributions("llog"))
sims_set_distributions <- function(x) {
  chk_is(x, "character")
  chk_no_missing(x)
  dists <- sims_distributions()
  x <- as.character(sort(unique(x)))
  options(sims.distributions = x)
  invisible(dists)
}
