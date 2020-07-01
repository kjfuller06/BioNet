# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)
library(sf)
library(raster)
library(tmap)

# load dataset and keep only the columns of interest
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
timefunction <- function(x) as.Date(x, format="%d/%m/%Y")
flora[c("DateFirst","DateLast")] = lapply(flora[c("DateFirst", "DateLast")], timefunction)

# 3. ####
# flora = flora %>% 
#   filter(Accuracy < 10,
#          -Status == "Invalid, in quarantine",
#          -Status == "Suspect")

# # convert to simple feature, with crs of GDA94 and the attributes being identifications
# map1 = st_as_sf(flora, coords = c("Longitude_GDA94", "Latitude_GDA94"), 
#          crs = 4283, agr = "identity")








