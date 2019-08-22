strip_comments <- function(x) {
  gsub("\\s*#[^\\\n]*", "", x)
}

data_files <- function(path) {
  list.files(path, pattern = "^data\\d{7,7}.rds$")
}

prepare_code <- function(code) {
  code <- strip_comments(code)
  if(grepl("^\\s*(data)|(model)\\s*[{]", code))
    err("jags code must not be in a data or model block.")
  code <- p0("model{", code, "}\n", collapse = "\n")
  code
}

stochastic_nodes <- function(x, stochastic) {
  if(isTRUE(stochastic)) {
    pattern <- "(?=\\s*[~])"
  } else if (isFALSE(stochastic)) {
    pattern <- "(?=\\s*(([<][-])|[=]))"  
  } else
    pattern <- "(?=\\s*([~]|(([<][-])|[=])))"
  
  index <- "\\[[^\\]]*\\]"
 
  pattern <- p0("[[:alnum:]_.]+(", index, "){0,1}\\s*[)]{0,1}", pattern, collapse = "")
  nodes <- str_extract_all(x, pattern)
  nodes <- unlist(nodes)
  nodes <- sub("[)]$", "", nodes)
  nodes <- sub("\\s*$", "", nodes)
  nodes <- str_replace(nodes, pattern = index, "")
  nodes <- unique(nodes)
  sort(nodes)
}

latent_nodes <- function(x, nodes, latent) {
  if(is.na(latent) || !length(nodes)) return(nodes)
  nodes. <- gsub("[.]", "[.]", nodes)
  patterns <- p0("([~]|([<][-])|(=))[^\n;]*\\b", nodes., 
                 "([^[:alnum:]_.]|\n|$)")
  lateo <- vapply(patterns, grepl, TRUE, x = x)
  if(latent) return(nodes[lateo])
  nodes[!lateo]
}

variable_nodes <- function (x, stochastic, latent) {
  x <- strip_comments(x)
  nodes <- stochastic_nodes(x, stochastic)
  nodes <- latent_nodes(x, nodes, latent)
  nodes
}

variable_nodes_description <- function(stochastic, latent) {
  desc <- "variable node"
  if(!is.na(stochastic)) 
    desc <- p(if(stochastic) "stochastic" else "deterministic", desc)
  if(!is.na(latent)) 
    desc <- p(if(latent) "latent" else "observed", desc)
  desc
}

set_monitor <- function(monitor, code, stochastic, latent, silent) {
  variable_nodes <- variable_nodes(code, stochastic, latent)
  desc <- variable_nodes_description(stochastic, latent)
  if(!length(variable_nodes)) 
    err("jags code must include at least one ", desc, ".")
  
  if(length(monitor) == 1) {
    monitor <- variable_nodes[grepl(monitor, variable_nodes)]
    if(!length(monitor)) 
      err("`monitor` must match at least one of the following ", desc, "s: ", 
          cc(variable_nodes, " or "), ".")
    return(monitor)
  }
  monitor <- unique(monitor)
  missing <- setdiff(monitor, variable_nodes)
  if(!length(missing)) return(monitor)
  
  if(length(missing) == length(monitor)) {
    err("`monitor` must include at least one of the following ", desc, "s: ", 
        cc(variable_nodes, " or "), ".")
  }
  if(!silent)
    wrn("The following in `monitor` are not ", desc, "s: ", cc(missing, " or "), ".")
  
  intersect(monitor, variable_nodes)
}

create_path <- function(path, exists, ask, silent) {
  dir_exists <- dir.exists(path)
  if(isFALSE(exists) && dir_exists) 
    err("Directory '", path, "' must not already exist.") 
  if(isTRUE(exists) && !dir_exists) 
    err("Directory '", path, "' must already exist.")
  if(!dir_exists) {
    dir.create(path, recursive = TRUE)
    return(TRUE)    
  }
  files <- list.files(path, pattern = "^data\\d{7,7}[.]rds$")
  if(length(files)) {
    if(ask && !yesno("Delete ", length(files), " sims data files in '", path, "'?"))
      err(length(files), " existing sims data files in '", path, "'.")
    if(!ask && !silent) 
      wrn("Deleted ", length(files), " sims data files in '", path, "'.")
    unlink(file.path(path, files))
  }
  if(file.exists(file.path(path, ".sims.rds")))
    unlink(file.path(path, ".sims.rds"))
}

as_natomic_mcarray <- function(x) {
  dim <- dim(x)
  ndim <- length(dim)
  x <- as.vector(x)
  dim(x) <- dim(x)[-c(ndim-1L,ndim)]
  x
}

data_file_name <- function(sim) p0("data", sprintf("%07d", sim), ".rds")

generate_dataset <- function(sim, code, constants, parameters, monitor, 
                             path, seed, parallel) {
  code <- textConnection(code)
  
  inits <- list(.RNG.name = "base::Wichmann-Hill")
  .Random.seed <<- seed
  inits$.RNG.seed <- abs(last(rinteger(sim)))
  
  data <- c(constants, parameters)
  model <- rjags::jags.model(code, data = data, inits = inits, 
                             n.adapt = 0, quiet = TRUE)
  sample <- rjags::jags.samples(model, variable.names = monitor, n.iter = 1L, 
                                progress.bar = "none")
  nlist <-  set_class(lapply(sample, as_natomic_mcarray), "nlist")
  nlist <- c(nlist, constants)
  if(is.null(path)) return(nlist)
  saveRDS(nlist, file.path(path, data_file_name(sim)))
  NULL
}

save_args <- function(path, ...) {
  args <- list(...)
  saveRDS(args, file.path(path, ".sims.rds"))
}

generate_datasets <- function(code, constants, parameters, monitor, nsims, 
                              path, parallel) {
  if (!exists(".Random.seed")) runif(1)
  seed <- .Random.seed
  if(!is.null(path)) {
    save_args(path, code = code, 
              constants = constants, parameters = parameters, 
              monitor = monitor, nsims = nsims, seed = seed)
  }

  if(parallel) {
    if(!requireNamespace("plyr", quietly = TRUE))
      err("Package plyr is required to batch process files in parallel.")
    nlists <- plyr::llply(1:nsims, generate_dataset,
                          code = code, 
                          constants = constants, parameters = parameters, 
                          monitor = monitor, 
                          path = path, seed = seed, parallel = parallel, 
                          .parallel = TRUE)
  } else {
    nlists <- lapply(1:nsims, generate_dataset,
                     code = code, 
                     constants = constants, parameters = parameters, 
                     monitor = monitor, 
                     path = path, seed = seed, parallel = parallel)
  }
  if(!is.null(path)) return(TRUE)
  set_class(nlists, "nlists")
}
