context("sims-data")

test_that("sims_data",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)
  
  set.seed(101)
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir),
               list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = 799289926L))
  
  data <- sims_data(tempdir)
  set.seed(101)
  expect_identical(data, sims_simulate("a ~ dunif(0,1)", nsims = 2L))
})
