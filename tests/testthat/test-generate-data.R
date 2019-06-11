context("generate-data")

test_that("model_to_data_block", {
  expect_identical(model_to_data_block("model{}"), 
                   "data {}\nmodel {\n  dummy <- 0 \n}")
  expect_identical(model_to_data_block("model { x <- 1 }"), 
                   "data { x <- 1 }\nmodel {\n  dummy <- 0 \n}")
  expect_identical(model_to_data_block("model  { for(i in 1:n) {b[i] ~ 1}}"), 
                   "data { for(i in 1:n) {b[i] ~ 1}}\nmodel {\n  dummy <- 0 \n}")
  expect_identical(model_to_data_block("
  model{
    for(i in 1:n) {
      b[i] ~ 1
    }
  }"), 
                   "\n  data {\n    for(i in 1:n) {\n      b[i] ~ 1\n    }\n  }\nmodel {\n  dummy <- 0 \n}")
})

test_that("set_parameters", {
  expect_identical(set_parameters("alpha ~ dunif(0, 1)\n", 
                                  c(alpha = 0.5)), 
                   "alpha <- 0.5\n")
  expect_identical(set_parameters("data{alpha ~ dunif(0, 1)}\n", 
                                  c(alpha = 0.5)), 
                   "data{alpha <- 0.5}\n")
  expect_identical(set_parameters("data{alpha ~ dunif(0, 1)}\n", 
                                  c(beta = 0.5)), 
                   "data{alpha ~ dunif(0, 1)}\n")
  expect_identical(set_parameters("data{alpha[1] ~ dunif(0, 1)}\n", 
                                  c(alpha = 0.5)), 
                   "data{alpha[1] ~ dunif(0, 1)}\n")
  expect_identical(set_parameters("data{alpha ~ dunif(0, 1)\nbeta <- alpha}\n", 
                                  c(alpha = 0.5)), 
                   "data{alpha <- 0.5\nbeta <- alpha}\n")
  expect_identical(set_parameters("data{alpha ~ dunif(0, 1)\nbeta <- alpha}\n", 
                                  c(alph = 0.2, alpha = 0.5)), 
                   "data{alpha <- 0.5\nbeta <- alpha}\n")
})
