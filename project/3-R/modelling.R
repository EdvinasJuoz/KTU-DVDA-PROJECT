library(h2o)
library(tidyverse)
h2o.init(max_mem_size = "8g")

fullData <- read.csv("../1-data/fullTrain.csv")
test_data <- read.csv("../1-data/test_data.csv")

dat <- data.frame(y=as.factor(fullData$y),term=as.factor(fullData$term),
                  credit_score=as.factor(fullData$credit_score),
                  home_ownership=as.factor(fullData$home_ownership),
                  loan_purpose=as.factor(fullData$loan_purpose),fullData[,-c(1,2,4,5,6,8)])

TESTdat <- data.frame(term=as.factor(test_data$term),
                      credit_score=as.factor(test_data$credit_score),
                      home_ownership=as.factor(test_data$home_ownership),
                      loan_purpose=as.factor(test_data$loan_purpose),test_data[,-c(1,3,4,5,7)])

h2o.init(max_mem_size = "8g")

quickH2O = as.h2o(dat)

splits <- h2o.splitFrame(quickH2O, c(0.9), seed=665)
train  <- h2o.assign(splits[[1]], "train") # 90%
valid  <- h2o.assign(splits[[2]], "valid") # 10%

quickfit <- h2o.gbm(x = 2:16, y = 1, training_frame = train,
                    nfolds=0,seed=665,ntrees = 600,learn_rate=0.05,
                    stopping_rounds = 5,stopping_tolerance = 1e-4,
                    stopping_metric = "AUC",sample_rate = 0.9,
                    col_sample_rate = 1,score_tree_interval = 10,
                    learn_rate_annealing = 0.99,max_depth = 24,
                    min_split_improvement = 1e-5,validation_frame = valid)

testH2o = as.h2o(TESTdat)

predictions <- h2o.predict(quickfit, testH2o)

predictions

library(tidyverse)
predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../5-predictions/predictions2.csv")

h2o.saveModel(quickfit, "../4-model/", filename = "GBM24")
