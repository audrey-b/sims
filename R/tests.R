model_to_data_block("model  { for(i in 1:n) {b[i] ~ 1}}") %>% cat

remove_priors("data{alpha ~ dunif(0, 1)\nbeta <- alpha}\n", 
              c(alpha = 0.5)) %>% cat

set.seed(101)
set_seed(list())

set.seed(102)
generate_data("model{beta ~ dunif(0,up) \n for(i in 1:5){alpha[i,2] = 2}}", 
              monitor = c("beta", "alpha"), 
              inits = list(),
              parameters = list("up"=1), 
              data = list())

