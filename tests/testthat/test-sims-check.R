context("sims-check")

test_that("sims_check",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)
  
  expect_error(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, 
                             exists = TRUE),
               "must already exist")
  
  set.seed(101)
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir),
               list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = NULL))
  expect_identical(sims_check(path = tempdir), 
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = NULL))
  
  file.remove(file.path(tempdir, "data0000001.rds"))
  expect_error(sims_check(path = tempdir), 
               "number of data files [(]1[)] does not match number of simulations [(]2[)]")
  file.remove(file.path(tempdir, "data0000002.rds"))
  expect_error(sims_check(path = tempdir), 
               "number of data files [(]0[)] does not match number of simulations [(]2[)]")
  
  
  file.create(file.path(tempdir, "data0000001.rds"))
  file.create(file.path(tempdir, "data0000003.rds"))
  expect_error(sims_check(path = tempdir),
               "data file names are not consistent withthe number of simulations [(]2[)]")
  file.remove(file.path(tempdir, .sims))
  expect_error(sims_check(path = tempdir),
               p0("must contain '", .sims, "'"))
})
