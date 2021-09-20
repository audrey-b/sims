rinteger <- function(n = 1) as.integer(runif(n, -2147483647L, 2147483647L))

set_class <- function(x, class) {
  class(x) <- class
  x
}

str_extract_all <- function(x, y) regmatches(x, gregexpr(y, x, perl = TRUE))

get_random_seed <- function() {
  if (!exists(".Random.seed")) runif(1)
  .Random.seed
}

set_random_seed <- function(seed, advance = FALSE) {
  .Random.seed <<- seed
  if (advance) runif(1)
  invisible(.Random.seed)
}

get_lecyer_cmrg_seed <- function() {
  seed <- get_random_seed()
  on.exit(set_random_seed(seed))
  RNGkind("L'Ecuyer-CMRG")
  set.seed(rinteger(1))
  get_random_seed()
}

# inspired by furrr:::generate_seed_streams
get_seed_streams <- function(nseeds) {
  seed <- get_lecyer_cmrg_seed()
  seeds <- vector("list", length = nseeds)
  for (i in seq_len(nseeds)) {
    seeds[[i]] <- parallel::nextRNGSubStream(seed)
    seed <- parallel::nextRNGStream(seed)
  }
  seeds
}
