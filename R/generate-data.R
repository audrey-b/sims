model_to_data_block <- function(model) {
  str_replace(model, "model\\s*[{]", "data {") %>% 
    str_replace("[}]\\s*$", "}\nmodel {\n  dummy <- 0 \n}")
}

set_parameters <- function(model, parameters) {
  for(i in seq_along(parameters)) {
    par <- parameters[i]
    pattern <- str_c(names(par), "\\s*~\\s*[^\n]+") 
    replacement <- str_c(names(par), " <- ", par)
    model %<>% str_replace(pattern, replacement)
  }
  model
}
