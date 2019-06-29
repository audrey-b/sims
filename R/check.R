check_variable_nodes <- function(x, y, y_name = substitute(y)) {
  variable_nodes <- variable_nodes(x)
  defined <- intersect(variable_nodes, names(y))
  if(length(defined)) {
    err(co_and(defined, p0("the following %n variable node%s %r defined in ", 
                           y_name, ": %c")))
  }
  return(x)
}
