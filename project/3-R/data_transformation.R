data <- read.csv("../1-data/1-sample_data.csv")
data1 <- read.csv("../1-data/2-additional_data.csv")
data2 <- read.csv("../1-data/3-additional_features.csv")

fullData = rbind(data,data1)
fullData = fullData[order(fullData$id),]
addData = data2[order(data2$id),]

fullData = cbind(fullData,addData[,-1])

library(readr)
write_csv(fullData, "../1-data/fullTrain.csv")