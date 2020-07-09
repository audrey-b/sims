context("rjags")

test_that("parallel.seeds is currently not reproducible", {
  set.seed(11)
  seed1 <- rjags::parallel.seeds("base::BaseRNG", 1)
  set.seed(11)
  seed2 <- rjags::parallel.seeds("base::BaseRNG", 1)

  expect_false(identical(seed1, seed2))
})

test_that("rjags replicable when prior in model", {
  code <- "model{beta ~ dunif(0,1)}"

  inits <- list(
    .RNG.name = "base::Wichmann-Hill",
    .RNG.seed = 799289926L
  )

  model1 <- rjags::jags.model(textConnection(code),
    data = list(),
    inits = inits,
    n.adapt = 0, quiet = TRUE
  )
  sample1 <- rjags::jags.samples(model1, variable.names = "beta", n.iter = 1)

  model2 <- rjags::jags.model(textConnection(code),
    data = list(),
    inits = inits,
    n.adapt = 0, quiet = TRUE
  )
  sample2 <- rjags::jags.samples(model2, variable.names = "beta", n.iter = 1)
  expect_identical(sample1, sample2)
})

test_that("rjags not replicable when prior in data", {
  code <- "data{beta ~ dunif(0,1)} model{dummy <- 0}"

  inits <- list(
    .RNG.name = "base::Wichmann-Hill",
    .RNG.seed = 799289926L
  )

  model1 <- rjags::jags.model(textConnection(code),
    data = list(),
    inits = inits,
    n.adapt = 0, quiet = TRUE
  )
  sample1 <- rjags::jags.samples(model1, variable.names = "beta", n.iter = 1)

  model2 <- rjags::jags.model(textConnection(code),
    data = list(),
    inits = inits,
    n.adapt = 0, quiet = TRUE
  )
  sample2 <- rjags::jags.samples(model2, variable.names = "beta", n.iter = 1)
  expect_false(identical(sample1, sample2))
})
