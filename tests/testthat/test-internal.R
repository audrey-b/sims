context("internal")

test_that("strip comments works", {
  expect_identical(strip_comments("x <- 1 # a comment"), 
                   "x <- 1")
  expect_identical(strip_comments("x <- 1 \n # a comment"), 
                   "x <- 1")
  expect_identical(strip_comments("x <- 1 \n y <- 2# a comment"), 
                   "x <- 1 \n y <- 2")
  expect_identical(strip_comments("x <- 1 #\n y <- 2# a comment"), 
                   "x <- 1\n y <- 2")
  
  expect_identical(strip_comments(c("x <- 1 #\n", "y <- # 3")), 
                   c("x <- 1\n", "y <-"))
})


test_that("variable_nodes either", {
  expect_identical(variable_nodes("a ~ dunif(0, 1)"), "a")
  expect_identical(variable_nodes("ab ~ dunif(0, 1)"), "ab")
  expect_identical(variable_nodes("b ~ dunif(0,1)\na ~ dunif(0, 1)"),
                   c("a", "b"))
  expect_identical(variable_nodes("a[] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a[1] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a[1,] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a[,] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a[i] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a[1,1:i] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a[1] ~ dunif(0,1)\na[2] ~ dunif(0, 1)"),
                   "a")
  expect_identical(variable_nodes("a <- dunif(0,1)"),
                   "a")
  expect_identical(variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)"),
                   c("a", "b"))
})

test_that("variable_nodes stochastic", {
  expect_identical(variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)",
                                      stochastic = TRUE),
                   "b")
})

test_that("variable_nodes deterministic", {
  expect_identical(variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)",
                                      stochastic = FALSE),
                   "a")
})

test_that("sum2intswrap", {
  mx <- 2147483647L
  expect_identical(sum2intswrap(0, 1), 1L)
  expect_identical(sum2intswrap(0, -1), -1L)
  
  expect_identical(sum2intswrap(mx, 0L), mx)
  expect_identical(sum2intswrap(-mx, 0L), -mx)

  expect_identical(sum2intswrap(mx, -1L), mx - 1L)
  expect_identical(sum2intswrap(-mx, 1L), -mx + 1L)

  expect_identical(sum2intswrap(mx, -mx), 0L)
  expect_identical(sum2intswrap(-mx, mx), 0L)
  
  expect_identical(sum2intswrap(mx, mx), 0L)
  expect_identical(sum2intswrap(-mx, -mx), 0L)
  
  expect_identical(sum2intswrap(mx, 1L), -2147483646L)
  expect_identical(sum2intswrap(mx, 2L), -2147483645L)
  expect_identical(sum2intswrap(-mx, -1L), 2147483646L)
  expect_identical(sum2intswrap(-mx, -2L), 2147483645L)
})

