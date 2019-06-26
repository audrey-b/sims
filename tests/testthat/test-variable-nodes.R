context("variable-nodes")

test_that("variable_nodes", {
  expect_identical(bsm_names_variable_nodes("a ~ dunif(0, 1)"), "a")
  expect_identical(bsm_names_variable_nodes("b ~ dunif(0,1)\na ~ dunif(0, 1)"),
                   c("a", "b"))
#  expect_identical(bsm_names_variable_nodes("a[1] ~ dunif(0, 1)"),
#                   c("a", "b"))
})
