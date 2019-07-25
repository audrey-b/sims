context("utils")

test_that("rcount", {
  set.seed(101)
  expect_identical(rcount(), 799289926L)
})
