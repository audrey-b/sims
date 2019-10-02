context("sims-rdists")

test_that("sims_rdists", {
  sims_rdists_reset()
  teardown(sims_rdists_reset())

  expect_identical(sims_rdists(), .sims_rdists)

  expect_identical(sims_rdists(), sims_rdists_add("a"))
  expect_identical(sims_rdists(), sort(c("a", .sims_rdists)))
  expect_identical(sims_rdists(), sims_rdists_add("rz"))
  expect_identical(sims_rdists(), sort(c("rz", "a", .sims_rdists)))
  expect_identical(sims_rdists(), sims_rdists_add("rz"))
  expect_identical(sims_rdists(), sort(c("rz", "a", .sims_rdists)))

  expect_identical(sims_rdists(), sims_rdists_set("rzz"))
  expect_identical(sims_rdists(), "rzz")

  expect_identical(sims_rdists(), sims_rdists_reset())
  expect_identical(sims_rdists(), .sims_rdists)
})
