context("sims-check")

test_that("sims_check",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)
  
  expect_error(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, 
                             write = NA, exists = TRUE),
               "must already exist")
  
  set.seed(101)
  expect_equal(sims_simulate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = NA),
               structure(list(structure(list(a = 0.0844208442995482), class = "nlist"), 
                              structure(list(a = 0.332673775219176), class = "nlist")), class = "nlists"))
  expect_identical(sims_check(path = tempdir), 
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = 799289926L))
  
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
  file.remove(file.path(tempdir, .argsims))
  expect_error(sims_check(path = tempdir),
               p0("must contain '", .argsims, "'"))
})
