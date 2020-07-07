## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well. The workflow is as follows:
#   1. Load dataset
#   2. Drop all columns not relevant to (most) species distribution modeling
#   3. Remove all instances except those in which Accuracy is less than 1km (1000m according to native units)
#   4. Remove all instances except those in which the difference between start and end dates is less than 7 days
#   5. Remove all instances except those listed as "accepted"
#   6. Remove all instances except those in which percent cover is less than or equal to 100
#   7. Generate unique survey IDs. BioNet data contain multiple instances in which replicates and/or subplots were surveyed in a given location, listing exactly the same coordinates on the same day.
#     -> 7.1. Generate a unique code for every distinct combination of Year + Lat/Lon.
#     -> 7.2. Generate a unique code for every distinct Biodiversity Assessment Method (BAM) survey.
#     -> 7.3. The user will need to decide how to address apparent duplicates in a given location.

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

# 5. ####
flora = flora %>% 
  filter(grepl("accepted", Status, ignore.case = TRUE))

backup = flora

# 6. ####
flora = flora %>% 
  filter(PercentCover <= 100 & PercentCover > 0)

# write to csv ####
write.csv(flora, file = "data samples/BioNet_allflorasurvey_cleaned.csv")











