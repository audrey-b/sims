context("simulate-data")

test_that("test inputs",{
  expect_error(bsm_simulate_data(1), 
               "code must be class character")
  
  expect_error(bsm_simulate_data("x <- y", 1), 
               "constants must be a list")
  expect_error(bsm_simulate_data("x <- y", list()), 
               "constants must have at least 1 element")
  expect_error(bsm_simulate_data("x <- y", list(1)), 
               "constants must be named")
  expect_error(bsm_simulate_data("x <- y", list(x = 1, x = 1)), 
               "names of constants must be unique")
  expect_error(bsm_simulate_data("x <- y", list(x = TRUE)), 
               "element x of constants must be mode numeric")
  expect_error(bsm_simulate_data("x <- y", list(x = NA_real_)), 
               "element x of constants must not include missing values")
  
  
  expect_error(bsm_simulate_data("x <- y", list(x = 1), 1), 
               "parameters must be a list")
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list()), 
               "parameters must have at least 1 element")
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list(1)), 
               "parameters must be named")
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list(x = 1, x = 1)), 
               "names of parameters must be unique")
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list(x = TRUE)), 
               "element x of parameters must be mode numeric")
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list(x = NA_real_)), 
               "element x of parameters must not include missing values")
  
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list(x = 1)), 
               "constants and parameters must have distinctly named elements")
  
  expect_error(bsm_simulate_data("x <- y", list(x = 1), list(y = 1), 1),
               "monitor must be class character")
})

test_that("test variable nodes not already defined",{
  expect_error(bsm_simulate_data("a ~ dunif(1)", list(a = 1), list(y = 1)),
               "the following 1 variable node is defined in constants: 'a'")
  expect_error(bsm_simulate_data("a ~ dunif(1)", list(y = 1), list(a = 1)),
               "the following 1 variable node is defined in parameters: 'a'")
})

test_that("test at least one stochastic node",{
  expect_error(bsm_simulate_data("a <- dunif(1)", list(x = 1), list(y = 1)),
               "jags code must include at least one stochastic variable")
  expect_error(bsm_simulate_data("a ~ dunif(1)", list(x = 1), list(y = 1), monitor = "b"),
               "monitor must match at least one of the following stochastic nodes: 'a'")
})

test_that("not in model or data block",{
  expect_error(bsm_simulate_data("a <- dunif(1)", list(x = 1), list(y = 1)),
               "jags code must include at least one stochastic variable")
  expect_error(bsm_simulate_data("model {a ~ dunif(1)}", list(x = 1), list(y = 1), monitor = "a"),
               "jags code must not be in a data or model block")
  expect_error(bsm_simulate_data("\n data\n{a ~ dunif(1)}", list(x = 1), list(y = 1), monitor = "a"),
               "jags code must not be in a data or model block")
})

test_that("generates data with replicability",{
  set.seed(101)
  expect_equal(bsm_simulate_data("a ~ dunif(0,1)", list(x = 1), list(y = 1)),
               list(a = 0.3289872), tolerance = 1e-06)
  set.seed(101)
  expect_equal(bsm_simulate_data("a ~ dunif(0,1)", list(x = 1), list(y = 1)),
               list(a = 0.3289872), tolerance = 1e-06)
})
