context("sims-nlist")

test_that("test inputs",{
  expect_error(sims_nlist(1),
               "code must be class character")
  
  expect_error(sims_nlist("x <- y", 1),
               "constants must be a list")
  expect_error(sims_nlist("x <- y", list()),
               "constants must be named")
  expect_error(sims_nlist("x <- y", list(1)),
               "constants must be named")
  expect_error(sims_nlist("x <- y", list(x = 1, x = 1)),
               "names of constants must be unique")
  expect_error(sims_nlist("x <- y", list(x = TRUE)),
               "element x of constants must be a numeric [(]integer or double[)] object")
  expect_error(sims_nlist("x <- y", list(x = NA_real_)),
               "element x of constants must not include missing values")
  
  expect_error(sims_nlist("x <- y", parameters = 1),
               "parameters must be a list")
  expect_error(sims_nlist("x <- y", parameters = list()),
               "parameters must be named")
  expect_error(sims_nlist("x <- y", parameters = list(1)),
               "parameters must be named")
  expect_error(sims_nlist("x <- y", parameters = list(x = 1, x = 1)),
               "names of parameters must be unique")
  expect_error(sims_nlist("x <- y", parameters = list(x = TRUE)),
               "element x of parameters must be a numeric [(]integer or double[)] object")
  expect_error(sims_nlist("x <- y", parameters = list(x = NA_real_)),
               "element x of parameters must not include missing values")
  
  expect_error(sims_nlist("x <- y", list(x = 1), monitor = 1),
               "monitor must be class character")
})

test_that("test variable nodes not already defined",{
  expect_error(sims_nlist("a ~ dunif(1)", list(a = 1)),
               "the following 1 variable node is defined in constants: 'a'")
})

test_that("test at least one stochastic node",{
  expect_error(sims_nlist("a <- dunif(1)", list(x = 1)),
               "jags code must include at least one stochastic variable")
  expect_error(sims_nlist("a ~ dunif(1)", list(x = 1), monitor = "b"),
               "monitor must match at least one of the following stochastic nodes: 'a'")
})

test_that("not in model or data block",{
  expect_error(sims_nlist("a <- dunif(1)", list(y = 1)),
               "jags code must include at least one stochastic variable")
  expect_error(sims_nlist("model {a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
  expect_error(sims_nlist("\n data\n{a ~ dunif(1)}", list(x = 1), monitor = "a"),
               "jags code must not be in a data or model block")
})

test_that("generates data with replicability",{
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 1L),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 1L),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist")), class = "nlists"))
})

test_that("issue if values in constants or parameters not in code",{
  # set.seed(101)
  # expect_equal(sims_nlist("a ~ dunif(0,1)", constants = list(x = 1)),
  #              structure(list(a = structure(
  #                0.3289872, .Dim = c(1L, 1L, 1L), class = "mcmcarray")),
  #                class = "mcmcr"), tolerance = 1e-06)
})

test_that("nsims can take numeric",{
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 1),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist")), class = "nlists"))
})

test_that("nsims > 1",{
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 2L),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist"), 
                              structure(list(a = 0.292819217930848), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 2L),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist"), 
                              structure(list(a = 0.292819217930848), class = "nlist")), class = "nlists"))
})

test_that("write replicable",{
  tempdir <- tempdir()
  teardown(unlink(tempdir, recursive = TRUE))
  
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = NA),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist")), class = "nlists"))
  set.seed(101)
  expect_error(sims_nlist("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = NA),
               "must not already exist")
  set.seed(101)
  expect_identical(sims_nlist("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = TRUE, exists = TRUE),
                   file.path(tempdir, "sims799289926"))
  set.seed(101)
  expect_identical(sims_nlist("a ~ dunif(0,1)", nsims = 1L, path = tempdir, write = TRUE, exists = TRUE),
                   file.path(tempdir, "sims799289926"))
  expect_identical(list.files(file.path(tempdir, "sims799289926")), "data0000001.rds")
})

test_that("monitor",{
  set.seed(101)
  expect_equal(sims_nlist("a ~ dunif(0,1)", nsims = 1),
               structure(list(structure(list(a = 0.0979623612132019), class = "nlist")), class = "nlists"))
  
  expect_error(sims_nlist("ab ~ dunif(0,1)", nsims = 1L, monitor = c("a", "a")),
               "monitor must include at least one of the following stochastic nodes: 'ab'")
  
  expect_warning(sims_nlist("ab ~ dunif(0,1)", nsims = 1L, monitor = c("ab", "a")),
                 "the following in monitor are not stochastic variables: 'a'")
})

test_that("append constants",{
  expect_error(sims_nlist("ab ~ dunif(0,1)", nsims = 1L, monitor = c("a", "a")),
               "monitor must include at least one of the following stochastic nodes: 'ab'")
  
  expect_warning(sims_nlist("ab ~ dunif(0,1)", nsims = 1L, monitor = c("ab", "a")),
                 "the following in monitor are not stochastic variables: 'a'")
})

