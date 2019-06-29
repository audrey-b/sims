strip_comments <- function(x) {
  str_replace_all(x, pattern = "\\s*#[^\\\n]*", replacement = "")
}

prepare_code <- function(code) {
  code <- strip_comments(code)
  if(str_detect(code, "^\\s*(data)|(model)\\s*[{]"))
    err("jags code must not be in a data or model block")
  code <- p0("model{", code, "}\n", collapse = "\n")
  code
}

variable_nodes <- function (x, stochastic = NA) {
  x <- strip_comments(x)
  
  if(isTRUE(stochastic)) {
    pattern <- "(?=\\s*[~])"
  } else if (isFALSE(stochastic)) {
    pattern <- "(?=\\s*[<][-])"  
  } else
    pattern <- "(?=\\s*([~]|([<][-])))"
  
  index <- "\\[[^\\]]*\\]"
  
  pattern <- p0("\\w+(", index, "){0,1}", pattern, collapse = "")
  nodes <- str_extract_all(x, pattern)
  nodes <- unlist(nodes)
  nodes <- str_replace(nodes, pattern = index, "")
  nodes <- unique(nodes)
  sort(nodes)
}

set_monitor <- function(monitor, code, silent) {
  stochastic_nodes <- variable_nodes(code, stochastic = TRUE)
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

set_seed <- function(inits) {
  inits$.RNG.name <- "base::Wichmann-Hill"
  inits$.RNG.seed <- as.integer(runif(1, 0, 2147483647))
  inits
}

generate_data <- function(code, data, monitor, nsims) {
  code <- prepare_code(code)
  inits <- set_seed(list())
  model <- rjags::jags.model(textConnection(code), data = data, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  sample <- rjags::jags.samples(model, variable.names = monitor, n.iter = nsims, 
                      progress.bar = "none")
  sample <-  lapply(sample, mcmcr::as.mcmcarray)
  as.mcmcr(sample)
}
