context("sims-copy")

test_that("sims_copy",{
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
  unlink(paste0(tempdir, "_copy"), recursive = TRUE)

  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = TRUE),
               c("argsims.rds", "data0000001.rds", "data0000002.rds"))
  expect_identical(sims_copy(path_from = tempdir),
                   c("argsims.rds", "data0000001.rds", "data0000002.rds"))
  expect_error(sims_copy(path_from = tempdir),
               "_copy' must not already exist")
  
  expect_identical(list.files(file.path(paste0(tempdir, "_copy"))), 
                   c("argsims.rds", "data0000001.rds", "data0000002.rds"))
  expect_equal(readRDS(file.path(paste0(tempdir, "_copy"), "data0000001.rds")),
                   structure(list(a = 0.0844208442995482), class = "nlist"))
  expect_equal(readRDS(file.path(paste0(tempdir, "_copy"), "data0000002.rds")),
                   structure(list(a = 0.332673775219176), class = "nlist"))
  
  expect_identical(readRDS(file.path(paste0(tempdir, "_copy"), "argsims.rds")),
                   list(code = "model{a ~ dunif(0,1)}\n", constants = structure(list(), .Names = character(0), class = "nlist"), 
    parameters = structure(list(), .Names = character(0), class = "nlist"), 
    monitor = "a", nsims = 2L, seed = 799289926L))
})
