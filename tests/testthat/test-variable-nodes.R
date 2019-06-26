context("variable-nodes")

test_that("variable_nodes either", {
  expect_identical(bsm_variable_nodes("a ~ dunif(0, 1)"), "a")
  expect_identical(bsm_variable_nodes("ab ~ dunif(0, 1)"), "ab")
  expect_identical(bsm_variable_nodes("b ~ dunif(0,1)\na ~ dunif(0, 1)"),
                   c("a", "b"))
  expect_identical(bsm_variable_nodes("a[] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a[1] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a[1,] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a[,] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a[i] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a[1,1:i] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a[1] ~ dunif(0,1)\na[2] ~ dunif(0, 1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a <- dunif(0,1)"),
                   "a")
  expect_identical(bsm_variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)"),
                   c("a", "b"))
})

test_that("variable_nodes stochastic", {
  expect_identical(bsm_variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)",
                                            stochastic = TRUE),
                   "b")
})

test_that("variable_nodes deterministic", {
  expect_identical(bsm_variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)",
                                            stochastic = FALSE),
                   "a")
})
