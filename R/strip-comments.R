#' Strip Comments
#'
#' Strips all \code{#} comments from a character vector.
#' 
#' @param x A character vector.
#'
#' @return The modified character vector.
#' @export
#'
#' @examples
#' bsm_strip_comments("x <- 1 # a comment")
bsm_strip_comments <- function(x) {
  str_replace_all(x, pattern = "\\s*#[^\\\n]*", replacement = "")
}
