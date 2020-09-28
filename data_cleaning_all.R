## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well. The workflow is as follows:
#   1. Load dataset
#   2. Drop all columns not relevant to (most) species distribution modeling
#   3. Remove all instances except those in which Accuracy is less than 1km (1000m according to native units)
#   4. Remove all instances except those in which the difference between start and end dates is less than 7 days
#   5. Remove all instances except those listed as "accepted"
#   6. Remove all instances except those in which percent cover is greater than 0%.
#   7. Generate a unique code for every distinct combination of Year + Lat/Lon. BioNet data contain multiple instances in which replicates and/or subplots were surveyed in a given location, listing exactly the same coordinates on the same day.
#       -> The user will need to decide how to address apparent duplicates in a given location.

# assign library path
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

# 6. ####
flora = flora %>% 
  filter(PercentCover > 0)

backup = flora

# 7. ####
unique = unique(flora[c("DateFirst", "DateLast", "Latitude_GDA94", "Longitude_GDA94")])
unique$ID = seq_len(nrow(unique))
flora = left_join(flora, unique)

# write to csv ####
write.csv(flora, file = "data samples/BioNet_allflorasurvey_cleaned.csv")

