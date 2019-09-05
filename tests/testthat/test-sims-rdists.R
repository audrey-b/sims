context("sims-rdists")

test_that("sims_rdists", {
  expect_identical(sims_rdists(), sort(paste0("r", c(
  "beta", "binom", "cauchy", "chisq", "exp", "f", "gamma", "geom", 
  "hyper", "lnorm", "multinom", "nbinom", "norm", "pois", "signrank", "t", 
  "unif", "weibull", "wilcox"))))
})
