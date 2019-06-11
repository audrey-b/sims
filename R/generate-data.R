model_to_data_block <- function(code) {
  str_replace(code, "model\\s*[{]", "data {") %>% 
    str_replace("[}]\\s*$", "}\nmodel {\n  dummy <- 0 \n}")
}

set_parameters <- function(code, parameters) {
  for(i in seq_along(parameters)) {
    par <- parameters[i]
    pattern <- str_c(names(par), "\\s*~\\s*[^\n}]+") 
    replacement <- str_c(names(par), " <- ", par)
    code %<>% str_replace(pattern, replacement)
  }
  code
}
