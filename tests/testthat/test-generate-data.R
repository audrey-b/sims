context("generate-data")

test_that("set_seed", {
  set.seed(101)
  expect_identical(set_seed(list()), 
                   list(.RNG.name = "base::Wichmann-Hill", 
                        .RNG.seed = 799289926L))
})

test_that("generate_data", {
  set.seed(102)
  data <- generate_data("model{beta ~ dunif(0,1)}", monitor = "beta", 
                fixed = list())
  expect_is(data, "list")
  expect_identical(names(data), "beta")
  expect_gte(data$beta, 0)
  expect_lte(data$beta, 1)
})

