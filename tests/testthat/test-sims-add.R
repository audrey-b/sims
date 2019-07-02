context("sims-add")

test_that("sims_add",{
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  
  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = TRUE),
                   c("argsims.rds", "data0000001.rds"))
  expect_identical(sims_add(nsims = 2L, path = tempdir), 
                   c("argsims.rds", "data0000002.rds", "data0000003.rds"))
  
  expect_identical(readRDS(file.path(tempdir, "argsims.rds")),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = 
                          structure(list(), .Names = character(0), class = "nlist"), 
                        parameters = structure(list(), .Names = character(0), class = "nlist"), 
                        monitor = "a", nsims = 3L, seed = 799289926L))
  expect_equal(readRDS(file.path(tempdir, "data0000001.rds")),
               structure(list(a = 0.0844208442995482), class = "nlist"))
  expect_equal(readRDS(file.path(tempdir, "data0000002.rds")),
               structure(list(a = 0.332673775219176), class = "nlist"))
})
