## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well. The workflow is as follows:
#   1. Load dataset
#   2. Drop all columns not relevant to (most) species distribution modeling
#   3. Remove all instances except those in which Accuracy is less than 1km (1000m according to native units)
#   4. Remove all instances except those in which the difference between start and end dates is less than 7 days

# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

# 1. & 2. ####
flora <- read.delim("data samples/BioNet_allflorasurvey.txt", header = TRUE, sep = "\t", dec = ".") %>%
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

# list columns that will be converted to factor variables
columns=c("Assgn_ScientificName","Exotic","NSWStatus","CommStatus","SensitivityClass","EstimateTypeCode","SourceCode","ObservationType","Status","Stratum","GrowthForm","CoverScore","AbundanceScore")
# convert columns to factors
flora[columns] = lapply(flora[columns], factor)

# convert columns to date variables
timefunction <- function(x) as.Date(x, format="%d/%m/%Y")
flora[c("DateFirst","DateLast")] = lapply(flora[c("DateFirst", "DateLast")], timefunction)

# 3. ####
flora = flora %>% 
  filter(Accuracy < 1000)

# 4. ####
flora = flora %>% 
  filter(DateLast - DateFirst < 8)













