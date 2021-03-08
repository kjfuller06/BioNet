# This script is for selecting species for analysis from all cleaned BioNet species records.
library(tidyverse)
library(rnaturalearth)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(raster)
library(spData)

#   1. Load datasets
#   2. Keep only records from target species and join bark traits to occurrence records.
#   3. Clip records using the boundary of NSW. Even though the data were already cleaned using CoordinateCleaner to remove points occurring in the ocean, this is still necessary because of stray points outside the state.

# 1. ####
flora = read.csv("outputs/BioNet_allfloralsurvey_cleaned2.csv")
sample = read.csv("data/Candidate_speciesV.1.csv")
traits = read.csv("data/Allspecies_traitsV.1.csv")

# 2. ####
flora = flora[flora$Assgn_ScientificName %in% sample$Bionet_assigned,] %>% 
  left_join(sample, by = c("Assgn_ScientificName" = "Bionet_assigned")) %>% 
  dplyr::select(-Assgn_ScientificName,
         -BioNet,
         -X) %>% 
  unique()
trees = traits %>% 
  filter(mallee != "mallee")
flora2 = flora %>% 
  left_join(trees)

mallees = traits %>% 
  filter(mallee == "mallee")
mallees2 = flora[flora$Nicolle19Name %in% mallees$Nicolle19Name,] %>% 
  left_join(mallees)

# 8. ####
# get Australia layer
aus = getData(name = "GADM", country = "AUS", level = 1, download = TRUE) %>% 
  st_as_sf()

# create NSW layer with ACT included
nsw = aus %>% 
  filter(NAME_1 == "New South Wales" | NAME_1 == "Australian Capital Territory") %>% 
  dplyr::select(geometry)

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

# now clip the nsw polygon using st_intersection
bound = st_intersection(nsw, bound)

# lastly, clip flora records by nsw boundary- minus islands
flora2 = st_as_sf(flora2, coords = c("Longitude_GDA94", "Latitude_GDA94"), crs = 4326)
flora2 = flora2[bound, ]
mallees2 = st_as_sf(mallees2, coords = c("Longitude_GDA94", "Latitude_GDA94"), crs = 4326)
mallees2 = mallees2[bound, ]

# 10. ####
st_write(flora2, "outputs/species_sampleV.1.shp", delete_layer = TRUE)
st_write(mallees2, "outputs/species_sampleV.1_mallees.shp", delete_layer = TRUE)
# st_write(bound, "outputs/NSW_sans_islands.shp", delete_layer = TRUE)
# st_write(aus, "outputs/australia.shp", delete_layer = TRUE)