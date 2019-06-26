#' Variable Nodes
#' 
#' Gets names of variable (as opposed to constant) nodes in JAGS model code.
#' 
#' @param x A string of JAGS model code
#' @param stochastic A flag specifying whether to get stochastic (TRUE), 
#' deterministic (FALSE) or both types (NA) of variable node.
#' @return A sorted character vector of the variable node names.
#' @export
#' @examples 
#' bsm_variable_nodes("a[1,1:i] ~ dunif(0, 1)")
bsm_variable_nodes <- function (x, stochastic = NA) {
  check_string(x)
  check_scalar(stochastic, c(TRUE, NA))

  x <- bsm_strip_comments(x)
  
  if(isTRUE(stochastic)) {
    pattern <- "(?=\\s*[~])"
  } else if (isFALSE(stochastic)) {
    pattern <- "(?=\\s*[<][-])"  
  } else
    pattern <- "(?=\\s*([~]|([<][-])))"
  
  index <- "\\[[^\\]]*\\]"
  
  pattern <- p0("\\w+(", index, "){0,1}", pattern, collapse = "")
  nodes <- str_extract_all(x, pattern)
  nodes <- unlist(nodes)
  nodes <- str_replace(nodes, pattern = index, "")
  nodes <- unique(nodes)
  sort(nodes)
}
