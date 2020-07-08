## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well. The workflow is as follows:
#   1. Load dataset
#   2. Drop all columns not relevant to my species distribution modeling
#   3. Remove all instances listed as SourceCode == "5" or "6" (i.e. "Sighting- Probable ID" and "Sighting- Possible ID", respectively
#   4. Remove all instances except those listed as observation type == "J"- Floristic Record from Systematic Flora Survey
#   5. Remove all instances except those in which Accuracy is less than or equal to 10m
#   6. Remove all instances except those originating since 1990
#   7. Remove columns SourceCode and ObservationType, as these are no longer relevant. And keep only Eucalypt records
#   8. Write to csv

# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)

# 1. & 2. ####
flora <- read.csv("data samples/BioNet_allflorasurvey_cleaned.csv", header = TRUE) %>% 
  dplyr::select(ID, 
                Assgn_ScientificName, 
                DateFirst,
                DateLast,
                SourceCode,
                ObservationType,
                Latitude_GDA94,
                Longitude_GDA94,
                Accuracy)

# 3. ####
flora = flora %>% 
  filter(SourceCode != 5 & SourceCode != 6)

# 4. ####
flora = flora %>% 
  filter(ObservationType == "J")

# 5. ####
flora = flora %>% 
  filter(Accuracy <= 10)

# 6. ####
timefunction <- function(x) as.Date(x, format="%Y-%m-%d")
flora[c("DateFirst","DateLast")] = lapply(flora[c("DateFirst", "DateLast")], timefunction)
flora = flora %>% 
  filter(DateFirst > 1989-12-31)

# 7. ####
backup = flora
flora = backup %>% 
  dplyr::select(ID, 
                Assgn_ScientificName, 
                DateFirst,
                DateLast,
                Latitude_GDA94,
                Longitude_GDA94,
                Accuracy) %>% 
  filter(grepl("Eucalyptus", Assgn_ScientificName, fixed = TRUE))

# 8. ####
write.csv(flora, "data samples/Eucalyptus_presence.csv")

