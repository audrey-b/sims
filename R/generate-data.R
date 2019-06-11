model_to_data_block <- function(code) {
  str_replace(code, "model\\s*[{]", "data {") %>% 
    str_replace("[}]\\s*$", "}\nmodel {\n  dummy <- 0 \n}")
}

set_parameters <- function(code, parameters) {
  for(i in seq_along(parameters)) {
    par <- parameters[i]
    pattern <- str_c(names(par), "\\s*~\\s*[^\n}]+") 
    replacement <- str_c(names(par), " <- ", par)
    code %<>% str_replace(pattern, replacement)
  }
  code
}

set_seed <- function(inits) {
  inits$.RNG.name <- "base::Wichmann-Hill"
  inits$.RNG.seed <- floor(runif(1, -2147483647, 2147483647))
  inits
}

generate_data <- function(code, monitor, parameters, data, inits) {
  code %<>% model_to_data_block() %>% 
    set_parameters(parameters)
  
  tempfile <- tempfile()
  writeLines(code, con = tempfile)
  
  inits %<>% set_seed()
  rjags::jags.model(tempfile, data, list(inits), n.adapt = 0, quiet = TRUE) %>%
  rjags::jags.samples(variable.names = monitor, n.iter = 1) %>%
    lapply(mcmcr::as.mcmcarray) %>%
    as.mcmcr() %>%
    estimates()
}
