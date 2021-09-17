use_local_plan <- function(strategy, mc.cores = 2L, env = parent.frame()) {
  old_options <- options(mc.cores = 2)
  withr::defer(options(old_options), envir = env)
  
  old_strategy <- future::plan(strategy)
  withr::defer(future::plan(old_strategy), envir = env)
  strategy
}
