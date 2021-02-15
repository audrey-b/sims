test_that("sims_rdists", {
  expect_identical(
    sims_rdists(),
    c(
      "rbeta", "rbinom", "rcauchy", "rchisq", "rexp", "rf", "rgamma", "rgeom",
      "rhyper", "rlnorm", "rmultinom", "rnbinom", "rnorm", "rpois", "rsignrank",
      "rt", "runif", "rweibull", "rwilcox"
    )
  )
})
