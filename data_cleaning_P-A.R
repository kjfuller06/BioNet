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
# get Australia layer
aus = getData(name = "GADM", country = "AUS", level = 1, download = TRUE) %>% 
  st_as_sf()

# create NSW layer with ACT included
nsw = aus %>% 
  filter(NAME_1 == "New South Wales" | NAME_1 == "Australian Capital Territory")

# create polygon with an extent that hugs the NSW coastline so we can snip off stray islands
# points are introduced in sequence as they would be drawn on paper, with the last coordinates repeated. So a square will have 5 points.
bound = list(c( 154, -38), c(140, -38), c( 140, -28), c( 154, -28), c( 154, -38)) %>%
  unlist() %>%
  matrix(ncol = 2,
         byrow = TRUE) %>% 
  # first convert to a linestring
  st_linestring %>% 
  # then convert to a polygon
  st_cast('POLYGON') %>% 
  st_sfc(crs = 4326)
## check plot
# ggplot()+
#   geom_sf(data = bound)+ 
#   geom_sf(data = nsw)

# now clip the nsw polygon using st_intersection
bound = st_intersection(nsw, bound)

# lastly, clip flora records by nsw boundary
flora2 = st_as_sf(flora, coords = c("Longitude_GDA94", "Latitude_GDA94"), crs = 4326) %>% 
  st_join(bound, join = st_within, left = FALSE)

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
st_write(bound, "data samples/NSW_sans_islands.shp", delete_layer = TRUE)
st_write(aus, "data samples/australia.shp", delete_layer = TRUE)
