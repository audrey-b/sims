generate_data <- function(code, fixed, monitor) {
  inits <- set_seed(list())
  
  model <- rjags::jags.model(textConnection(code), data = fixed, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  rjags::jags.samples(model, variable.names = monitor, n.iter = 1)  %>%
   lapply(mcmcr::as.mcmcarray) %>%
   as.mcmcr() %>%
   estimates()
}
