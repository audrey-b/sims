check_variable_nodes <- function(x, y, rdists, y_name = substitute(y)) {
  variable_nodes <-
    variable_nodes(x, stochastic = NA, latent = NA, rdists = rdists)
  defined <- intersect(variable_nodes, names(y))
  if (length(defined)) {
    err(
      "The following variable nodes are defined in ",
      y_name, ": ", cc(defined, " and "), "."
    )
  }
  x
}

strip_comments <- function(x) {
  gsub("\\s*#[^\\\n]*", "", x)
}

data_files <- function(path) {
  list.files(path, pattern = "^data\\d{7,7}.rds$")
}

is_jags_code <- function(code) {
  grepl("~", code)
}

prepare_code <- function(code) {
  code <- strip_comments(code)
  if (is_jags_code(code)) {
    if (grepl("^\\s*(data)|(model)\\s*[{]", code)) {
      err("JAGS code must not be in a data or model block.")
    }
    code <- p0("model{", code, "}\n", collapse = "\n")
  }
  code
}

stochastic_nodes_pattern <- function(x, pattern) {
  pattern <- p0("(?=\\s*(", pattern, "))")

  index <- "\\[[^\\]]*\\]"

  pattern <- p0("[[:alnum:]_.]+(", index, "){0,1}\\s*[)]{0,1}",
    pattern,
    collapse = ""
  )
  nodes <- str_extract_all(x, pattern)
  nodes <- unlist(nodes)
  nodes <- sub("[)]$", "", nodes)
  nodes <- sub("\\s*$", "", nodes)
  nodes <- sub(pattern = index, "", nodes, perl = TRUE)
  nodes <- unique(nodes)
  sort(nodes)
}

stochastic_nodes_jags <- function(x, stochastic) {
  pattern <- "[~]|([<][-])|[=]"
  if (isTRUE(stochastic)) pattern <- "[~]"
  if (isFALSE(stochastic)) pattern <- "([<][-])|[=]"
  stochastic_nodes_pattern(x, pattern)
}

stochastic_nodes_r <- function(x, stochastic, rdists) {
  if (isTRUE(stochastic) && !length(rdists)) {
    err(
      "R code must include at least one stochastic variable node.",
      " Did you mean to set `rdists` = character(0)?"
    )
  }

  if (is.na(stochastic) || (isFALSE(stochastic) && !length(rdists))) {
    return(stochastic_nodes_jags(x, stochastic = FALSE))
  }

  pattern <- paste0("(", rdists, ")", collapse = "|")
  pattern <- paste0("(", pattern, ")\\(")
  pattern <- paste0("(([<][-])|[=])\\s*", pattern)

  stochastic_nodes <- stochastic_nodes_pattern(x, pattern)
  if (isTRUE(stochastic)) {
    return(stochastic_nodes)
  }
  setdiff(stochastic_nodes_jags(x, stochastic = FALSE), stochastic_nodes)
}

stochastic_nodes <- function(x, stochastic, rdists) {
  if (is_jags_code(x)) {
    return(stochastic_nodes_jags(x, stochastic))
  }
  stochastic_nodes_r(x, stochastic, rdists)
}

latent_nodes <- function(x, nodes, latent) {
  if (is.na(latent) || !length(nodes)) {
    return(nodes)
  }
  nodes2 <- gsub("[.]", "[.]", nodes)
  patterns <- p0(
    "([~]|([<][-])|(=))[^\n;]*\\b", nodes2,
    "([^[:alnum:]_.]|\n|$)"
  )
  lateo <- vapply(patterns, grepl, TRUE, x = x)
  if (latent) {
    return(nodes[lateo])
  }
  nodes[!lateo]
}

variable_nodes <- function(x, stochastic, latent, rdists = character(0)) {
  nodes <- stochastic_nodes(x, stochastic, rdists)
  nodes <- latent_nodes(x, nodes, latent)
  nodes
}

variable_nodes_description <- function(stochastic, latent) {
  desc <- "variable node"
  if (!is.na(stochastic)) {
    desc <- p(if (stochastic) "stochastic" else "deterministic", desc)
  }
  if (!is.na(latent)) {
    desc <- p(if (latent) "latent" else "observed", desc)
  }
  desc
}

set_monitor <- function(monitor, code, stochastic, latent, rdists, silent) {
  variable_nodes <- variable_nodes(code, stochastic, latent, rdists = rdists)
  desc <- variable_nodes_description(stochastic, latent)

  if (!length(variable_nodes)) {
    err(
      if (is_jags_code(code)) "JAGS" else "R",
      " code must include at least one ", desc, "."
    )
  }

  if (length(monitor) == 1) {
    monitor <- variable_nodes[grepl(monitor, variable_nodes)]
    if (!length(monitor)) {
      err(
        "`monitor` must match at least one of the following ", desc, "s: ",
        cc(variable_nodes, " or "), "."
      )
    }
    return(monitor)
  }
  monitor <- unique(monitor)
  missing <- setdiff(monitor, variable_nodes)
  if (!length(missing)) {
    return(monitor)
  }

  if (length(missing) == length(monitor)) {
    err(
      "`monitor` must include at least one of the following ", desc, "s: ",
      cc(variable_nodes, " or "), "."
    )
  }
  if (!silent) {
    wrn(
      "The following in `monitor` are not ", desc, "s: ",
      cc(missing, " or "), "."
    )
  }

  intersect(monitor, variable_nodes)
}

create_path <- function(path, exists, ask, silent) {
  dir_exists <- dir.exists(path)
  if (isFALSE(exists) && dir_exists) {
    err("Directory '", path, "' must not already exist.")
  }
  if (isTRUE(exists) && !dir_exists) {
    err("Directory '", path, "' must already exist.")
  }
  if (!dir_exists) {
    dir.create(path, recursive = TRUE)
    return(TRUE)
  }
  files <- list.files(path, pattern = "^data\\d{7,7}[.]rds$")
  if (length(files)) {
    if (ask && !yesno(
      "Delete ", length(files), " sims data files in '",
      path, "'?"
    )) {
      err(length(files), " existing sims data files in '", path, "'.")
    }
    if (!ask && !silent) {
      wrn("Deleted ", length(files), " sims data files in '", path, "'.")
    }
    unlink(file.path(path, files))
  }
  if (file.exists(file.path(path, ".sims.rds"))) {
    unlink(file.path(path, ".sims.rds"))
  }
}

as_natomic_mcarray <- function(x) {
  dim <- dim(x)
  x <- as.vector(x)
  ndim <- length(dim)
  dim <- dim[-c(ndim - 1L, ndim)]
  if (length(dim) > 1) {
    dim <- unname(dim)
    dim(x) <- dim
  }
  x
}

data_file_name <- function(sim) p0("data", sprintf("%07d", sim), ".rds")

generate_jags <- function(code, data, monitor) {
  code <- textConnection(code)

  inits <- list(.RNG.name = "base::Wichmann-Hill")
  inits$.RNG.seed <- abs(rinteger(1))

  model <- rjags::jags.model(code,
    data = data, inits = inits,
    n.adapt = 0, quiet = TRUE
  )
  sample <- rjags::jags.samples(model,
    variable.names = monitor, n.iter = 1L,
    progress.bar = "none"
  )
  set_class(lapply(sample, as_natomic_mcarray), "nlist")
}

generate_r <- function(code, data, monitor) {
  nlist <- within(data, eval(code))[monitor]
  class(nlist) <- "nlist"
  chk_nlist(nlist, x_name = "simulations from `code`")
  nlist
}

generate_dataset <- function(sim, code, is_jags, constants, parameters, monitor,
                             save, path, parallel, p) {
  if(!is.null(p)) p(message = "none")
  data <- c(constants, parameters)
  class(data) <- NULL

  nlist <- if (is_jags) {
    generate_jags(code = code, data = data, monitor = monitor)
  } else {
    generate_r(code = code, data = data, monitor = monitor)
  }

  nlist <- c(nlist, constants)
  if (!isFALSE(save)) saveRDS(nlist, file.path(path, data_file_name(sim)))
  if (isTRUE(save)) {
    return(NULL)
  }
  nlist
}

save_args <- function(path, ...) {
  args <- list(...)
  saveRDS(args, file.path(path, ".sims.rds"))
}

generate_datasets <- function(code, constants, parameters, monitor, nsims,
                              save, path) {
  seed <- get_random_seed()
  on.exit(set_random_seed(seed, advance = TRUE))

  if (!isFALSE(save)) {
    save_args(path,
      code = code,
      constants = constants, parameters = parameters,
      monitor = monitor, nsims = nsims, seed = seed
    )
  }

  if (is_jags_code(code)) {
    is_jags <- TRUE
    if(!requireNamespace("rjags", quietly = TRUE))
      err("Package 'rjags' must be installed to simulate data using JAGS code.")
  } else {
    is_jags <- FALSE
    code <- parse(text = code)
  }
  sims <- 1:nsims
  if(requireNamespace("progressr", quietly = TRUE)) {
    p <- progressr::progressor(along = sims)
  } else 
    p <- NULL
  nlists <- future_lapply(sims,
    FUN = generate_dataset,
    code = code, is_jags = is_jags,
    constants = constants, parameters = parameters,
    monitor = monitor, save = save,
    path = path, future.seed = get_seed_streams(nsims), p = p
  )
  if (isTRUE(save)) {
    return(TRUE)
  }
  set_class(nlists, "nlists")
}
