## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well. The workflow is as follows:
#   1. Load dataset
#   2. Drop all columns not relevant to my species distribution modeling
#   3. Remove all instances except those listed as observation type == "J"- Floristic Record from Systematic Flora Survey
#   4. Remove all instances except those in which Accuracy is less than or equal to 10m
#   5. Remove all instances except those originating since 1990

# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

# 1. & 2. ####
flora <- read.csv("data samples/BioNet_allflorasurvey_cleaned.csv", header = TRUE) %>% 
  dplyr::select(Assgn_ScientificName, 
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

backup1 = flora

# list columns that will be converted to factor variables
columns=c("Assgn_ScientificName","EstimateTypeCode","SourceCode","ObservationType","Status","Stratum","GrowthForm","CoverScore","AbundanceScore")
# convert columns to factors
flora[columns] = lapply(flora[columns], factor)

backup2 = flora

# convert columns to date variables
timefunction <- function(x) as.Date(x, format="%Y-%m-%d")
flora[c("DateFirst","DateLast")] = lapply(flora[c("DateFirst", "DateLast")], timefunction)

# 3. ####


# # convert to simple feature, with crs of GDA94 and the attributes being identifications
# map1 = st_as_sf(flora, coords = c("Longitude_GDA94", "Latitude_GDA94"), 
#          crs = 4283, agr = "identity")








