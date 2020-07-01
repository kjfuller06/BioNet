## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well


# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

# load dataset and keep only the columns of interest
columns=c("Assgn_ScientificName","Exotic","NSWStatus","CommStatus","SensitivityClass","EstimateTypeCode","SourceCode","ObservationType","Status","Stratum","GrowthForm","CoverScore","AbundanceScore")
# flora <- read.delim("data samples/BioNet_allflorasurvey.txt", header = TRUE, sep = "\t", dec = ".") 
flora = read.csv("data samples/all_minus_P-A_data.csv", header = TRUE) %>% 
  dplyr::select(Assgn_ScientificName, 
                Exotic, 
                NSWStatus,
                CommStatus,
                SensitivityClass,
                DateFirst,
                DateLast,
                NumberIndividuals,
                EstimateTypeCode,
                SourceCode,
                ObservationType,
                Status,
                Latitude_GDA94,
                Longitude_GDA94,
                Accuracy,
                Stratum,
                GrowthForm,
                CoverScore,
                AbundanceScore,
                PercentCover,
                LowerHeight,
                UpperHeight)
flora[columns] = lapply(flora[columns], factor)
timefunction <- function(x) as.Date(x, format="%d/%m/%Y")
flora[c("DateFirst","DateLast")] = lapply(flora[c("DateFirst", "DateLast")], timefunction)
