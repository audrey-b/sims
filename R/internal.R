set_class <- function(x, class) {
  class(x) <- class
  x
}

strip_comments <- function(x) {
  str_replace_all(x, pattern = "\\s*#[^\\\n]*", replacement = "")
}

data_files <- function(path, args = TRUE) {
  list.files(path, pattern = "^data\\d{7,7}.rds$")
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

  pattern <- p0("\\w+(", index, "){0,1}\\s*[)]{0,1}", pattern, collapse = "")
  nodes <- str_extract_all(x, pattern)
  nodes <- unlist(nodes)
  nodes <- str_replace(nodes, pattern = "[)]$", "")
  nodes <- str_replace(nodes, pattern = "\\s*$", "")
  nodes <- str_replace(nodes, pattern = index, "")
  nodes <- unique(nodes)
  sort(nodes)
}

set_monitor <- function(monitor, code, silent) {
  variable_nodes <- variable_nodes(code)
  if(!length(variable_nodes)) 
    err("jags code must include at least one variable node")
  
  if(length(monitor) == 1) {
    monitor <- variable_nodes[str_detect(variable_nodes, monitor)]
    if(!length(monitor)) 
      err(co_or(variable_nodes, 
                "monitor must match at least one of the following variable nodes: %c"))
    return(monitor)
  }
  monitor <- unique(monitor)
  missing <- setdiff(monitor, variable_nodes)
  if(!length(missing)) return(monitor)
  
  if(length(missing) == length(monitor)) {
    err(co_or(variable_nodes, 
              "monitor must include at least one of the following variable nodes: %c"))
  }
  if(!silent)
    wrn(co_or(missing, "the following in monitor are not variable nodes: %c"))
  
  intersect(monitor, variable_nodes)
}

create_path <- function(path, exists) {
  dir_exists <- dir.exists(path)
  if(isFALSE(exists) && dir_exists) 
    err("directory '", path, "' must not already exist") 
  if(isTRUE(exists) && !dir_exists) 
    err("directory '", path, "' must already exist")
  if(dir_exists) unlink(path, recursive = TRUE)
  dir.create(path, recursive = TRUE)
}

set_seed_inits <- function(seed, inits = list()) {
  set.seed(seed)
  inits$.RNG.name <- "base::Wichmann-Hill"
  inits$.RNG.seed <- as.integer(runif(1, 0, .max_integer))
  inits
}

as_natomic_mcarray <- function(x) {
  dim <- dim(x)
  ndim <- length(dim)
  x <- as.vector(x)
  dim(x) <- dim(x)[-c(ndim-1L,ndim)]
  x
}

data_file_name <- function(sim) p0("data", sprintf("%07d", sim), ".rds")

generate_dataset <- function(sim, seed, code, constants, parameters, monitor, write, path) {
  code <- textConnection(code)
  inits <- set_seed_inits(seed)
  data <- c(constants, parameters)
  model <- rjags::jags.model(code, data = data, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  sample <- rjags::jags.samples(model, variable.names = monitor, n.iter = 1L, 
                                progress.bar = "none")
  nlist <-  set_class(lapply(sample, as_natomic_mcarray), "nlist")
  nlist <- c(nlist, constants)
  if(!isFALSE(write)) saveRDS(nlist, file.path(path, data_file_name(sim)))
  if(isTRUE(write)) return(NULL)
  nlist
}

save_args <- function(path, ...) {
  args <- list(...)
  saveRDS(args, file.path(path, ".argsims.rds"))
}

generate_datasets <- function(code, constants, parameters, monitor, nsims, seed, 
                              write, path) {
  set.seed(seed)
  seeds <- rcount(nsims)
  
  if(!isFALSE(write)) {
    save_args(path, code = code, 
              constants = constants, parameters = parameters, 
              monitor = monitor, nsims = nsims, seed = seed)
  }
  
  nlists <- mapply(FUN = generate_dataset, 1:nsims, seeds,  
                   MoreArgs = list(code = code, 
                                   constants = constants, parameters = parameters, 
                                   monitor = monitor, 
                                   write = write, path = path),
                   SIMPLIFY = FALSE)
  if(isTRUE(write)) return(data_files(path))
  set_class(nlists, "nlists")
}
