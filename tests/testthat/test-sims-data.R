context("sims-data")

test_that("sims_data",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)
  
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, seed = 2L),
               list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = 2L))
  
  data <- sims_data(tempdir)
  expect_identical(data, sims_simulate("a ~ dunif(0,1)", nsims = 2L, seed = 2L))
})
