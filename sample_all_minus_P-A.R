# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

flora <- read.delim("Do Not Sync/BioNet_allflorasurvey.txt", header = TRUE, sep = "\t", dec = ".")
sample2 <- flora %>% 
  dplyr::filter(is.na(CoverScore)==FALSE|is.na(AbundanceScore)==FALSE|is.na(PercentCover)==FALSE|is.na(LowerHeight)==FALSE|is.na(UpperHeight)==FALSE) %>% 
  dplyr::filter(grepl("Eucalyptus", Assgn_ScientificName))
sample2 <- droplevels(sample2)

options = list()
a = 1
for (i in sample2[,44:48]){
  b = i
  options[[a]] = length(b[is.na(b) == FALSE])
  a = a+1
  }

write.csv(sample2,"Do Not Sync/all_minus_P-A_data.csv")

