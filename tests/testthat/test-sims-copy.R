context("sims-copy")

test_that("sims_copy",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)

  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = TRUE),
               c("argsims.rds", "data0000001.rds", "data0000002.rds"))
#  sims_copy(path_from = tempdir)
})
