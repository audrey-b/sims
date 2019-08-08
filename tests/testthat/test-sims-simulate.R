context("sims-simulate")

test_that("test inputs",{
  expect_error(sims_simulate(1),
               "code must be class character")
  
  expect_error(sims_simulate("x <- y", 1),
               "constants must be a list")
  expect_error(sims_simulate("x <- y", list()),
               "constants must be named")
  expect_error(sims_simulate("x <- y", list(1)),
               "constants must be named")
  expect_error(sims_simulate("x <- y", list(x = 1, x = 1)),
               "names of constants must be unique")
  expect_error(sims_simulate("x <- y", list(x = TRUE)),
               "element x of constants must be a numeric [(]integer or double[)] object")
  expect_error(sims_simulate("x <- y", list(x = NA_real_)),
               "element x of constants must not include missing values")
  
  expect_error(sims_simulate("x <- y", parameters = 1),
               "parameters must be a list")
  expect_error(sims_simulate("x <- y", parameters = list()),
               "parameters must be named")
  expect_error(sims_simulate("x <- y", parameters = list(1)),
               "parameters must be named")
  expect_error(sims_simulate("x <- y", parameters = list(x = 1, x = 1)),
               "names of parameters must be unique")
  expect_error(sims_simulate("x <- y", parameters = list(x = TRUE)),
               "element x of parameters must be a numeric [(]integer or double[)] object")
  expect_error(sims_simulate("x <- y", parameters = list(x = NA_real_)),
               "element x of parameters must not include missing values")
  
  expect_error(sims_simulate("x <- y", list(x = 1), monitor = 1),
               "monitor must be class character")
})

test_that("test nodes not already defined",{
  expect_error(sims_simulate("a ~ dunif(1)", list(a = 1)),
               "the following 1 variable node is defined in constants: 'a'")
})

test_that("test match at least one node",{
  expect_error(sims_simulate("a ~ dunif(1)", list(x = 1), monitor = "b"),
               "monitor must match at least one of the following variable nodes: 'a'")
})

test_that("not in model or data block",{
  expect_error(sims_simulate("model {a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
  expect_error(sims_simulate("\n data\n{a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
})

test_that("generates data with replicability",{
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1L, seed = 3L),
               structure(list(structure(list(a = 0.480573861883504), class = "nlist")), class = "nlists"))
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1L, seed = 3L),
               structure(list(structure(list(a = 0.480573861883504), class = "nlist")), class = "nlists"))
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1L, seed = -3L),
               structure(list(structure(list(a = 0.587498637596841), class = "nlist")), class = "nlists"))
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1L, seed = 3L),
               structure(list(structure(list(a = 0.480573861883504), class = "nlist")), class = "nlists"))
})

test_that("generates data with replicability by setting seed",{
  set.seed(7L)
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1L),
               structure(list(structure(list(a = 0.559857624785649), class = "nlist")), class = "nlists"))
  set.seed(7L)
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1L),
               structure(list(structure(list(a = 0.559857624785649), class = "nlist")), class = "nlists"))
})

test_that("issue if values in constants or parameters not in code",{
  # set.seed(101)
  # expect_equal(sims_simulate("a ~ dunif(0,1)", constants = list(x = 1)),
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
  
  skip_on_os("windows")
  expect_equal(sims_simulate(generative_model, 
                             constants = constants,
                             parameters = parameters,
                             monitor = monitor, nsims = 3L,
                             seed = 2L),
               structure(list(structure(list(C = c(31, 34, 26, 20, 16), lambda = c(32.0212581683725, 
29.2301292225158, 26.6822886806137, 24.3565303394963, 22.2334964320294
), rand = -0.0227419291174858, Year = 1:5), class = "nlist"), 
    structure(list(C = c(23, 24, 18, 23, 23), lambda = c(32.0212581683725, 
    29.2301292225158, 26.6822886806137, 24.3565303394963, 22.2334964320294
    ), rand = 0.207187145386696, Year = 1:5), class = "nlist"), 
    structure(list(C = c(43, 20, 25, 26, 24), lambda = c(32.0212581683725, 
    29.2301292225158, 26.6822886806137, 24.3565303394963, 22.2334964320294
    ), rand = -0.432496093743802, Year = 1:5), class = "nlist")), class = "nlists"))
})

test_that("nsims can take numeric",{
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1, seed = 5L),
               structure(list(structure(list(a = 0.536394304516007), class = "nlist")), class = "nlists"))
})

test_that("nsims > 1",{
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 2L, seed = 6L),
               structure(list(structure(list(a = 0.643005716928864), class = "nlist"), 
    structure(list(a = 0.62107998665903), class = "nlist")), class = "nlists"))
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 2L, seed = 6L),
               structure(list(structure(list(a = 0.643005716928864), class = "nlist"), 
    structure(list(a = 0.62107998665903), class = "nlist")), class = "nlists"))
})

test_that("write replicable",{
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir),
               list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 1L, seed = -548903793L))
  set.seed(101)
  expect_error(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir),
               "must not already exist")
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, exists = TRUE),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 1L, seed = -548903793L))
  
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, exists = TRUE),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 1L, seed = -548903793L))
  expect_identical(sims_data_files(tempdir), 
                   "data0000001.rds")
  expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
               structure(list(a = 0.209508333947602), class = "nlist"))
  
  expect_identical(sims_info(tempdir),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 1L, seed = -548903793L))
})

test_that("write replicable > 1",{
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir),
               list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = -548903793L))
  set.seed(101)
  expect_error(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir),
               "must not already exist")
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, exists = TRUE),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = -548903793L))
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, 
                                 exists = TRUE, seed = 101),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = 101L))
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, exists = TRUE),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 1L, seed = -548903793L))
  set.seed(101)
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, exists = TRUE),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = -548903793L))
  expect_identical(sims_data_files(tempdir), 
                   c("data0000001.rds", "data0000002.rds"))
  expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
               structure(list(a = 0.209508333947602), class = "nlist"))
  expect_equal(readRDS(file.path(tempdir, "data0000002.rds")),
               structure(list(a = 0.585330878314009), class = "nlist"))
  
  expect_identical(sims_info(tempdir),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 2L, seed = -548903793L))
})

test_that("monitor",{
  set.seed(101)
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 1),
               structure(list(structure(list(a = 0.209508333947602), class = "nlist")), class = "nlists"))
  
  expect_error(sims_simulate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("a", "a")),
               "monitor must include at least one of the following variable nodes: 'ab'")
  
  expect_warning(sims_simulate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("ab", "a")),
                 "the following in monitor are not variable nodes: 'a'")
})

test_that("append constants",{
  expect_error(sims_simulate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("a", "a")),
               "monitor must include at least one of the following variable nodes: 'ab'")
  
  expect_warning(sims_simulate("ab ~ dunif(0,1)", nsims = 1L, monitor = c("ab", "a")),
                 "the following in monitor are not variable nodes: 'a'")
})

test_that("parallel with registered", {
  # tempdir <- file.path(tempdir(), "sims")
  # unlink(tempdir, recursive = TRUE)
  # 
  # doParallel::registerDoParallel(2)
  # teardown(doParallel::stopImplicitCluster())
  # 
  # set.seed(101)
  # expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 1L, seed parallel = FALSE),
  #              list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
  #   parameters = structure(list(), .Names = character(0), class = "nlist"), 
  #   monitor = "a", nsims = 2L, seed = -548903793L))
  # 
  # set.seed(101)
  # expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 2L, parallel = TRUE, path = tempdir),
  #              list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
  #   parameters = structure(list(), .Names = character(0), class = "nlist"), 
  #   monitor = "a", nsims = 2L, seed = -548903793L))
  # 
  # 
  # expect_identical(sims_data_files(tempdir), 
  #                  c("data0000001.rds", "data0000002.rds"))
  # 
  # expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
  #              structure(list(a = 0.209508333947602), class = "nlist"))
  # expect_equal(readRDS(file.path(tempdir, "data0000002.rds")),
  #              structure(list(a = 0.585330878314009), class = "nlist"))
})

