set_monitor <- function(monitor, code) {
  stochastic_nodes <- bsm_variable_nodes(code, stochastic = TRUE)
  if(!length(stochastic_nodes)) 
    err("jags code must include at least one stochastic variable")
  to_monitor <- stochastic_nodes[str_detect(stochastic_nodes, monitor)]
  if(!length(to_monitor)) 
    err(co_or(stochastic_nodes, 
              "monitor must match at least one of the following stochastic nodes: %c"))
  to_monitor
}
