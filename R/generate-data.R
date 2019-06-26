set_seed <- function(inits) {
  inits$.RNG.name <- "base::Wichmann-Hill"
  inits$.RNG.seed <- as.integer(runif(1, 0, 2147483647))
  inits
}

generate_data <- function(code, variables, monitor) {
  inits <- set_seed(list())
  
  model <- rjags::jags.model(textConnection(code), data = variables, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  rjags::jags.samples(model, variable.names = monitor, n.iter = 1)  %>%
   lapply(mcmcr::as.mcmcarray) %>%
   as.mcmcr() %>%
   estimates()
}
