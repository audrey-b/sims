context("sims-copy")

test_that("sims_copy",{
  tempdir <- tempdir()
  unlink(tempdir, recursive = TRUE)

  set.seed(101)
  expect_identical(sims_generate("a ~ dunif(0,1)", nsims = 2L, path = tempdir, write = TRUE),
               file.path(tempdir, "sims"))
  
  sims_copy(path_from = tempdir)
  

})
