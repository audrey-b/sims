context("sims-generate")

test_that("test inputs",{
  expect_error(sims_generate(1),
               "code must be class character")
  
  expect_error(sims_generate("x <- y", 1),
               "constants must be a list")
  expect_error(sims_generate("x <- y", list()),
               "constants must be named")
  expect_error(sims_generate("x <- y", list(1)),
               "constants must be named")
  expect_error(sims_generate("x <- y", list(x = 1, x = 1)),
               "names of constants must be unique")
  expect_error(sims_generate("x <- y", list(x = TRUE)),
               "element x of constants must be a numeric [(]integer or double[)] object")
  expect_error(sims_generate("x <- y", list(x = NA_real_)),
               "element x of constants must not include missing values")
  
  expect_error(sims_generate("x <- y", parameters = 1),
               "parameters must be a list")
  expect_error(sims_generate("x <- y", parameters = list()),
               "parameters must be named")
  expect_error(sims_generate("x <- y", parameters = list(1)),
               "parameters must be named")
  expect_error(sims_generate("x <- y", parameters = list(x = 1, x = 1)),
               "names of parameters must be unique")
  expect_error(sims_generate("x <- y", parameters = list(x = TRUE)),
               "element x of parameters must be a numeric [(]integer or double[)] object")
  expect_error(sims_generate("x <- y", parameters = list(x = NA_real_)),
               "element x of parameters must not include missing values")
  
  expect_error(sims_generate("x <- y", list(x = 1), monitor = 1),
               "monitor must be class character")
})

test_that("test nodes not already defined",{
  expect_error(sims_generate("a ~ dunif(1)", list(a = 1)),
               "the following 1 variable node is defined in constants: 'a'")
})

test_that("test match at least one node",{
  expect_error(sims_generate("a ~ dunif(1)", list(x = 1), monitor = "b"),
               "monitor must match at least one of the following variable nodes: 'a'")
})

test_that("not in model or data block",{
  expect_error(sims_generate("model {a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
  expect_error(sims_generate("\n data\n{a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
})

test_that("generates data with replicability",{
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 1L),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 1L),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist")), class = "nlists"))
})

test_that("issue if values in constants or parameters not in code",{
  # set.seed(101)
  # expect_equal(sims_generate("a ~ dunif(0,1)", constants = list(x = 1)),
  #              structure(list(a = structure(
  #                0.3289872, .Dim = c(1L, 1L, 1L), class = "mcmcarray")),
  #                class = "mcmcr"), tolerance = 1e-06)
})

test_that("gets deterministic nodes", {
  
  generative_model <- "
rand ~ dnorm(0,1)
for (i in 1:length(Year)){
  C[i] ~ dpois(lambda[i])
  log(lambda[i]) <- alpha + beta1 * Year[i]
}
"
  monitor <- c("C", "rand", "lambda")
  
  parameters <- list(alpha = 3.5576, beta1 = -0.0912)
  
  constants <- list(Year = 1:5)
  
  expect_equal(sims_generate(generative_model, 
                                 constants = constants,
                                 parameters = parameters,
                                 monitor = monitor, nsims = 3L,
                                 seed = 2L),
                   structure(list(structure(list(C = c(40, 24, 18, 19, 24), lambda = c(32.0212581683725, 
                                                                                       29.2301292225158, 26.6822886806137, 24.3565303394963, 22.2334964320294
                   ), rand = 1.27926545901677, Year = 1:5), class = "nlist"), structure(list(
                     C = c(33, 31, 18, 25, 15), lambda = c(32.0212581683725, 29.2301292225158, 
                                                           26.6822886806137, 24.3565303394963, 22.2334964320294), rand = 1.29633543073257, 
                     Year = 1:5), class = "nlist"), structure(list(C = c(36, 20, 
                                                                         30, 28, 17), lambda = c(32.0212581683725, 29.2301292225158, 26.6822886806137, 
                                                                                                 24.3565303394963, 22.2334964320294), rand = 1.13001728245729, 
                                                                   Year = 1:5), class = "nlist")), class = "nlists"))
  
})

test_that("nsims can take numeric",{
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 1),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist")), class = "nlists"))
})

test_that("nsims > 1",{
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 2L),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist"), 
                              structure(list(a = 0.332673775219176), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 2L),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist"), 
                              structure(list(a = 0.332673775219176), class = "nlist")), class = "nlists"))
})

test_that("write replicable",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)
  
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = NA),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_error(sims_generate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = NA),
               "must not already exist")
  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = TRUE, exists = TRUE),
                   "data0000001.rds")
  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = TRUE, exists = TRUE),
                   "data0000001.rds")
  expect_identical(list.files(tempdir), 
                   "data0000001.rds")
  expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
               structure(list(a = 0.0844208442995482), class = "nlist"))
  
  expect_identical(readRDS(file.path(tempdir, .argsims)),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 1L, seed = 799289926L))
})

test_that("write replicable > 1",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)
  
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = NA),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist"), 
                              structure(list(a = 0.332673775219176), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_error(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = NA),
               "must not already exist")
  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = TRUE, exists = TRUE),
                   c("data0000001.rds", "data0000002.rds"))
  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = TRUE, exists = TRUE),
                   c("data0000001.rds", "data0000002.rds"))
  expect_identical(list.files(file.path(tempdir)), 
                   c("data0000001.rds", "data0000002.rds"))
  expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
               structure(list(a = 0.0844208442995482), class = "nlist"))
  expect_equal(readRDS(file.path(tempdir, "data0000002.rds")),
               structure(list(a = 0.332673775219176), class = "nlist"))
  
  expect_identical(readRDS(file.path(tempdir, .argsims)),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 2L, seed = 799289926L))
})

test_that("monitor",{
  set.seed(101)
  expect_equal(sims_generate("a ~ dunif(0,1)", nsims = 1),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist")), class = "nlists"))
  
  expect_error(sims_generate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("a", "a")),
               "monitor must include at least one of the following variable nodes: 'ab'")
  
  expect_warning(sims_generate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("ab", "a")),
                 "the following in monitor are not variable nodes: 'a'")
})

test_that("append constants",{
  expect_error(sims_generate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("a", "a")),
               "monitor must include at least one of the following variable nodes: 'ab'")
  
  expect_warning(sims_generate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("ab", "a")),
                 "the following in monitor are not variable nodes: 'a'")
})

