context("simulate-data")

test_that("test inputs",{
  expect_error(bsm_simulate_data(1), 
               "jags_code must be class character")
  
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
