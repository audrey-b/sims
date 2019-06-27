#' Named List of Zero-Length
#'
#' @return An zero-length named list.
#' @export
#'
#' @examples
#' named_list()
named_list <- function() {
  structure(list(), .Names = character(0))
}
