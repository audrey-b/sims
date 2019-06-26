model_to_data_block <- function(code) {
  str_replace(code, "model\\s*[{]", "data {") %>% 
    str_replace("[}]\\s*$", "}\nmodel {\n  dummy <- 0 \n}")
}

remove_priors <- function(code, parameters) {
  for(i in seq_along(parameters)) {
    par <- parameters[i]
    pattern <- str_c(names(par), "\\s*~\\s*[^\n}]+") 
    replacement <- "\n"
    code %<>% str_replace(pattern, replacement)
  }
  code
}

set_seed <- function(inits) {
  inits$.RNG.name <- "base::Wichmann-Hill"
  inits$.RNG.seed <- as.integer(runif(1, 0, 2147483647))
  inits
}

generate_data <- function(code, monitor, parameters, data, inits) {
  code %<>% model_to_data_block() %>% 
    remove_priors(parameters)

  inits %<>% set_seed()
  
  model <- rjags::jags.model(textConnection(code), data = parameters, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  rjags::jags.samples(model, variable.names = monitor, n.iter = 1)  %>%
   lapply(mcmcr::as.mcmcarray) %>%
   as.mcmcr() %>%
   estimates()
}
