context("simulate-data")

test_that("test inputs",{
  expect_error(bsm_simulate_data(1), 
               "code must be class character")
  
  expect_error(bsm_simulate_data("x <- y", 1), 
               "fixed must be a list")
  expect_error(bsm_simulate_data("x <- y", list()), 
               "fixed must be named")
  expect_error(bsm_simulate_data("x <- y", list(1)), 
               "fixed must be named")
  expect_error(bsm_simulate_data("x <- y", list(x = 1, x = 1)), 
               "names of fixed must be unique")
  expect_error(bsm_simulate_data("x <- y", list(x = TRUE)), 
               "element x of fixed must be mode numeric")
  expect_error(bsm_simulate_data("x <- y", list(x = NA_real_)), 
               "element x of fixed must not include missing values")
  
  expect_error(bsm_simulate_data("x <- y", list(x = 1), 1),
               "monitor must be class character")
})

test_that("test variable nodes not already defined",{
  expect_error(bsm_simulate_data("a ~ dunif(1)", list(a = 1)),
               "the following 1 variable node is defined in fixed: 'a'")
})

test_that("test at least one stochastic node",{
  expect_error(bsm_simulate_data("a <- dunif(1)", list(x = 1)),
               "jags code must include at least one stochastic variable")
  expect_error(bsm_simulate_data("a ~ dunif(1)", list(x = 1), monitor = "b"),
               "monitor must match at least one of the following stochastic nodes: 'a'")
})

test_that("not in model or data block",{
  expect_error(bsm_simulate_data("a <- dunif(1)", list(y = 1)),
               "jags code must include at least one stochastic variable")
  expect_error(bsm_simulate_data("model {a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
  expect_error(bsm_simulate_data("\n data\n{a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
})

test_that("generates data with replicability",{
  set.seed(101)
  expect_equal(bsm_simulate_data("a ~ dunif(0,1)", nsamples = 1L),
               structure(list(a = structure(
                 0.3289872, .Dim = c(1L, 1L, 1L), class = "mcmcarray")), 
                 class = "mcmcr"), tolerance = 1e-06)
  set.seed(101)
  expect_equal(bsm_simulate_data("a ~ dunif(0,1)", nsamples = 1L),
               structure(list(a = structure(
                 0.3289872, .Dim = c(1L, 1L, 1L), class = "mcmcarray")), 
                 class = "mcmcr"), tolerance = 1e-06)
})

test_that("nsamples can take numeric",{
  set.seed(101)
  expect_equal(bsm_simulate_data("a ~ dunif(0,1)", nsamples = 1),
               structure(list(a = structure(
                 0.3289872, .Dim = c(1L, 1L, 1L), class = "mcmcarray")), 
                 class = "mcmcr"), tolerance = 1e-06)
})

test_that("monitor",{
  set.seed(101)
  expect_equal(bsm_simulate_data("a ~ dunif(0,1)", nsamples = 1L, monitor = "a"),
               structure(list(a = structure(
                 0.3289872, .Dim = c(1L, 1L, 1L), class = "mcmcarray")), 
                 class = "mcmcr"), tolerance = 1e-06)
  expect_error(bsm_simulate_data("ab ~ dunif(0,1)", nsamples = 1L, monitor = c("a", "a")),
                "monitor must include at least one of the following stochastic nodes: 'ab'")
  
  expect_warning(bsm_simulate_data("ab ~ dunif(0,1)", nsamples = 1L, monitor = c("ab", "a")),
                "the following in monitor are not stochastic variables: 'a'")
})
