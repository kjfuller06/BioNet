# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

flora <- read.delim("BioNet_allflorasurvey.txt", header = TRUE, sep = "\t", dec = ".")
sample <- flora %>% 
  dplyr::filter(ScientificName == "Eucalyptus viminalis")
sample <- droplevels(sample)
str(sample)
summary(sample)
write.csv(sample,"e.viminalis.csv")

