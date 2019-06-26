prepare_jags_code <- function(jags_code) {
  jags_code <- bsm_strip_comments(jags_code)
  if(str_detect(jags_code, "^\\s*(data)|(model)\\s*[{]"))
    err("jags code must not be in a data or model block")
  jags_code
}
