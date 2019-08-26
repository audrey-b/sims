rinteger <- function(n = 1) as.integer(runif(n, -.max_integer, .max_integer))

set_class <- function(x, class) {
  class(x) <- class
  x
}

last <- function(x) x[length(x)]

str_extract_all <- function(x, y) regmatches(x, gregexpr(y, x, perl = TRUE))
