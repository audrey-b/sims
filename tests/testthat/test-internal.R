test_that("strip comments works", {
  expect_identical(
    strip_comments("x <- 1 # a comment"),
    "x <- 1"
  )
  expect_identical(
    strip_comments("x <- 1 \n # a comment"),
    "x <- 1"
  )
  expect_identical(
    strip_comments("x <- 1 \n y <- 2# a comment"),
    "x <- 1 \n y <- 2"
  )
  expect_identical(
    strip_comments("x <- 1 #\n y <- 2# a comment"),
    "x <- 1\n y <- 2"
  )

  expect_identical(
    strip_comments(c("x <- 1 #\n", "y <- # 3")),
    c("x <- 1\n", "y <-")
  )
})


test_that("variable_nodes either", {
  expect_identical(variable_nodes("a ~ dunif(0, 1)",
    stochastic = NA, latent = NA
  ), "a")
  expect_identical(variable_nodes("ab ~ dunif(0, 1)",
    stochastic = NA, latent = NA
  ), "ab")
  expect_identical(
    variable_nodes("b ~ dunif(0,1)\na ~ dunif(0, 1)",
      stochastic = NA, latent = NA
    ),
    c("a", "b")
  )
  expect_identical(
    variable_nodes("a[] ~ dunif(0, 1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a[1] ~ dunif(0, 1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a[1,] ~ dunif(0, 1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a[,] ~ dunif(0, 1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a[i] ~ dunif(0, 1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a[1,1:i] ~ dunif(0, 1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a[1] ~ dunif(0,1)\na[2] ~ dunif(0, 1)",
      stochastic = NA, latent = NA
    ),
    "a"
  )
  expect_identical(
    variable_nodes("a <- dunif(0,1)", stochastic = NA, latent = NA),
    "a"
  )
  expect_identical(
    variable_nodes("a <- dunif(0,1)\nb ~ dunif(0,1)",
      stochastic = NA, latent = NA
    ),
    c("a", "b")
  )
})
