context("strip-comments")

test_that("strip comments works", {
  expect_identical(bsm_strip_comments("x <- 1 # a comment"), 
                   "x <- 1")
  expect_identical(bsm_strip_comments("x <- 1 \n # a comment"), 
                   "x <- 1")
  expect_identical(bsm_strip_comments("x <- 1 \n y <- 2# a comment"), 
                   "x <- 1 \n y <- 2")
  expect_identical(bsm_strip_comments("x <- 1 #\n y <- 2# a comment"), 
                   "x <- 1\n y <- 2")
  
  expect_identical(bsm_strip_comments(c("x <- 1 #\n", "y <- # 3")), 
                   c("x <- 1\n", "y <-"))
})
