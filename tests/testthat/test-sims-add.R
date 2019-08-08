context("sims-add")

test_that("sims_add",{
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  
  expect_identical(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, seed = 101),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 1L, seed = 101L))
  
  expect_error(sims_add(nsims = 1000000L, path = tempdir),
               "adding the simulations would result in more than 1,000,000 datasets")
                   
  expect_identical(sims_add(nsims = 2L, path = tempdir), 
                   c("data0000002.rds", "data0000003.rds"))
  
  expect_identical(sims_info(tempdir),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = 
                          structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 3L, seed = 101L))
  expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
               structure(list(a = 0.247694617962275), class = "nlist"))
  expect_equal(readRDS(file.path(tempdir, "data0000002.rds")),
               structure(list(a = 0.951518742613052), class = "nlist"))
})
