check_variable_nodes <- function(x, y, y_name = substitute(y)) {
  variable_nodes <- bsm_variable_nodes(x)
  defined <- intersect(variable_nodes, names(y))
  if(length(defined)) {
    err(co_and(defined, p0("the following %n variable node%s %r defined in ", 
           y_name, ": %c")))
  }
  return(x)
}

check_distinct_names <- function(...) {
  x <- list(...)
  names <- vapply(x, names, "", USE.NAMES = FALSE)
  if(anyDuplicated(names)) 
    err(cc(names(x), "and", ""), " must have distinctly named elements")
  x[[1]]
}

check_numeric_vma <- function(x, x_name = substitute(x)) {
  x_name <- chk_deparse(x_name)
  if(!(is.vector(x) || is.matrix(x) || is.array(x)))
     err(x_name, " must be a vector, matrix or array")
  if(!is.numeric(x)) err(x_name, " must be mode numeric")
  check_length(x, x_name = x_name)
  if(any(is.na(x))) err(x_name, " must not include missing values")
  x
}

check_data_list <- function(x, x_name = substitute(x)) {
  x_name <- chk_deparse(x_name)
  check_list(x, x_name = x_name)
  check_length(x, x_name = x_name)
  check_named(x, unique = TRUE, x_name = x_name)
  mapply(check_numeric_vma, x, p("element", names(x), "of", x_name))
  x
}
