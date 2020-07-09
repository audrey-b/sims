#' Sims Random R Distributions
#'
#' Gets the names of the R random variate generating functions
#' listed in [Distributions()].
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' sims_rdists()
sims_rdists <- function() {
  c(
    "rbeta", "rbinom", "rcauchy", "rchisq", "rexp", "rf", "rgamma", "rgeom",
    "rhyper", "rlnorm", "rmultinom", "rnbinom", "rnorm", "rpois", "rsignrank",
    "rt", "runif", "rweibull", "rwilcox"
  )
}
