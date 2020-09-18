## This file is for selecting useful columns and performing some common cleaning processes that could be useful for other scientists at the HIE and outside as well. The workflow is as follows:
#   1. Load dataset
#   2. Drop all columns not relevant to my species distribution modeling
#   3. Remove all instances listed as SourceCode == "5" or "6" (i.e. "Sighting- Probable ID" and "Sighting- Possible ID", respectively
#   4. Remove all instances except those listed as observation type == "J"- Floristic Record from Systematic Flora Survey
#   5. Remove all instances except those in which Accuracy is less than or equal to 10m
#   6. Remove all instances except those originating since 1990
#   7. Remove columns SourceCode and ObservationType, as these are no longer relevant. Keep only records from target species and join bark traits from Bronwyn Horsey's records to occurrence records.
#   8. Clip records using the boundary of NSW
#   9. Write to csv

library(tidyverse)
library(rnaturalearth)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(raster)
library(spData)
library(tmap)

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
sample = read.csv("data samples/Horsey_candidate_speciesV.1.csv")
flora = backup %>% 
  dplyr::select(ID, 
                Assgn_ScientificName, 
                DateFirst,
                DateLast,
                Latitude_GDA94,
                Longitude_GDA94,
                Accuracy)
flora = flora[flora$Assgn_ScientificName %in% sample$species,] %>% 
  left_join(sample, by = c("Assgn_ScientificName" = "species"))

# 8. ####
# aus = ne_countries(scale = 110, country = "australia", returnclass = "sf") %>% 
#   dplyr::select(geometry)
aus = world[world$name_long == "Australia",] %>% 
  dplyr::select(geom)

flora2 = st_as_sf(flora, coords = c("Longitude_GDA94", "Latitude_GDA94"), crs = 4326) %>% 
  st_join(aus, join = st_within, left = FALSE)

# ggplot(data = aus)+
#   geom_sf()+
#   geom_sf(data = flora2, 
#           aes(color = Assgn_ScientificName))+
#   coord_sf(xlim = c(140, 155), ylim = c(-38, -27), expand = FALSE)+
#   theme(legend.position="none")

# tmap_mode("view")
# qtm(flora2,
#     dots.col = "Assgn_ScientificName")

# 9. ####
st_write(flora2, "data samples/Horsey_sampleV.1.shp", delete_layer = TRUE)
