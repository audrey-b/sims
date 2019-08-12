context("sims-add")

test_that("sims_simulate no problem random to seed being set",{
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)
 
  expect_true(sims_simulate("a ~ dunif(0,1)", nsims = 1L, path = tempdir))
})