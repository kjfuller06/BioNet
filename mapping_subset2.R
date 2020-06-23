# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

# load dataset
flora <- read.csv("data samples/all_minus_P-A_data.csv", header = TRUE)

# determine the number of observations in each cover estimate metric
options = list()
a = 1
for (i in flora[,44:48]){
  b = i
  options[[a]] = length(b[is.na(b) == FALSE])
  a = a+1
}
