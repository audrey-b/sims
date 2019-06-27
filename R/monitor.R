set_monitor <- function(monitor, code, silent) {
  stochastic_nodes <- bsm_variable_nodes(code, stochastic = TRUE)
  if(!length(stochastic_nodes)) 
    err("jags code must include at least one stochastic variable")
  
  if(length(monitor) == 1) {
    monitor <- stochastic_nodes[str_detect(stochastic_nodes, monitor)]
    if(!length(monitor)) 
      err(co_or(stochastic_nodes, 
                "monitor must match at least one of the following stochastic nodes: %c"))
    return(monitor)
  }
  monitor <- unique(monitor)
  missing <- setdiff(monitor, stochastic_nodes)
  if(!length(missing)) return(monitor)
  
  if(length(missing) == length(monitor)) {
    err(co_or(stochastic_nodes, 
              "monitor must include at least one of the following stochastic nodes: %c"))
  }
  if(!silent)
    wrn(co_or(missing, "the following in monitor are not stochastic variables: %c"))
  
  intersect(monitor, stochastic_nodes)
}
