context("rjags")

test_that("parallel.seeds is currently not reproducible",{
  set.seed(11)
  seed1 <- rjags::parallel.seeds("base::BaseRNG", 1)
  set.seed(11)
  seed2 <- rjags::parallel.seeds("base::BaseRNG", 1)
  
  expect_false(identical(seed1, seed2))
})