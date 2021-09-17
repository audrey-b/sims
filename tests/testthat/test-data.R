test_that("sims_data", {
  tempdir <- file.path(tempdir(), "sims")
  unlink(tempdir, recursive = TRUE)

  withr::local_seed(2)
  expect_true(sims_simulate("a ~ dunif(0,1)",
    nsims = 10L,
    path = tempdir, save = TRUE
  ))

  data <- sims_data(tempdir)
  withr::local_seed(2)
  expect_identical(data, sims_simulate("a ~ dunif(0,1)", nsims = 10L))
})
