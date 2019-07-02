context("utils")

test_that("sims_rcount", {
  set.seed(101)
  expect_identical(sims_rcount(), 799289926L)
})
