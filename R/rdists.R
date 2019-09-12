#' Sims Random R Distributions
#' 
#' Gets the names of the random variate generating R functions recognized by sims 
#' as producing stochastic variable nodes.
#' 
#' By default the functions are the random variate generating functions
#' listed in \code{\link{Distributions}}.
#'
#' @return A character vector of the names of random variate generating R functions.
#' @seealso \code{\link{sims_rdists_add}()} and  
#' \code{\link{sims_rdists_reset}()}
#' @export
#'
#' @examples
#' sims_rdists()
sims_rdists <- function() {
  getOption("sims.rdists", .sims_rdists)
}

#' Sims Add Distributions
#' 
#' Adds sims distributions.
#' 
#' @param x A character vector of the random variate generating R functions.
#' @return A invisible character vector of the names of the previous R distributions.
#' @seealso \code{\link{sims_rdists}()} and  
#' \code{\link{sims_rdists_reset}()}
#' @export
#'
#' @examples
#' print(sims_rdists_add("llog"))
sims_rdists_add <- function(x) {
  chk_s3_class(x, "character"); chk_no_missing(x)
  
  dists <- sims_rdists()
  x <- as.character(sort(unique(c(dists, x))))
  options(sims.rdists = x)
  invisible(dists)
}

#' Sims Reset Distributions
#'
#' Resets sims distributions.
#'   
#' @return A invisible character vector of the names of the previous R distributions.
#' @seealso \code{\link{sims_rdists}()} and  
#' \code{\link{sims_rdists_set}()}
#' @export
#'
#' @examples
#' print(sims_rdists_reset())
sims_rdists_reset <- function() {
  dists <- sims_rdists()
  options(sims.rdists = NULL)
  invisible(dists)
}

#' Sims Set Distributions
#'
#'  Sets sims distributions.
#'
#' @param x A character vector of the random variate generating R functions.   
#' @return A invisible character vector of the names of the previous R distributions.
#' @seealso \code{\link{sims_rdists}()} and  
#' \code{\link{sims_rdists_reset}()}
#' @export
#'
#' @examples
#' print(sims_rdists_set("llog"))
sims_rdists_set <- function(x) {
  chk_s3_class(x, "character"); chk_no_missing(x)
  dists <- sims_rdists()
  x <- as.character(sort(unique(x)))
  options(sims.rdists = x)
  invisible(dists)
}
