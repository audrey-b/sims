generate_data <- function(code, fixed, monitor, nsamples) {
  inits <- set_seed(list())
  
  model <- rjags::jags.model(textConnection(code), data = fixed, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  sample <- rjags::jags.samples(model, variable.names = monitor, n.iter = nsamples, 
                      progress.bar = "none")
  sample <-  lapply(sample, mcmcr::as.mcmcarray)
  as.mcmcr(sample)
}
