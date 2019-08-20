check_variable_nodes <- function(x, y, y_name = substitute(y)) {
  variable_nodes <- variable_nodes(x, stochastic = NA, observed = NA)
  defined <- intersect(variable_nodes, names(y))
  if(length(defined)) {
    err("The following variable nodes are defined in ", 
                           y_name, ": ", cc(defined, " and "), ".")
  }
  x
}
