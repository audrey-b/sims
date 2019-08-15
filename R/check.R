check_variable_nodes <- function(x, y, y_name = substitute(y)) {
  variable_nodes <- variable_nodes(x)
  defined <- intersect(variable_nodes, names(y))
  if(length(defined)) {
    err("the following variable nodes are defined in ", 
                           y_name, ": ", cc(defined, " and "))
  }
  x
}
