# Script is for checking suspicious data in a subset of BioNet flora survey data concerning cover and abundance estimates of Eucalypts species only. This subset has been coined "P-A" for Presence-Absence, meaning these surveys can be used to generate presence/absence data for species distribution modeling.

# there's a variable I haven't examined I might want to include in the final subset, which is NumberIndividuals

# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)
library(sf)
library(raster)
library(tmap)
library(vctrs)

# load dataset
flora <- read.csv("data samples/all_minus_P-A_data.csv", header = TRUE)

# determine the number of observations in each cover estimate metric
options = data.frame(types = names(flora[,45:49]), obs = c(1, 2, 3, 4, 5))
a = 1
for (i in flora[,45:49]){
  b = i
  options[a, 2] = length(b[is.na(b) == FALSE])
  a = a+1
}
options

# select only the unique plot IDs. There are 59,438 survey plots.
flora2 = flora %>% 
  dplyr::select(DateFirst, DateLast, LocationKey, Latitude_GDA94, Longitude_GDA94, Accuracy, Stratum, GrowthForm, CoverScore, AbundanceScore, PercentCover, LowerHeight, UpperHeight) %>% 
  filter(Accuracy <= 10)

# convert Date First to three columns in a data frame
datecheck = as.data.frame(stringr::str_split_fixed(as.character(flora2$DateFirst), pattern = "/", n = 3))
length(datecheck$V3[datecheck$V3 == 1970])
## 126 records for 1970
# check for 126 records of the date 01/01/1970
flora2$DateFirst <- as.Date(flora2$DateFirst, format = "%d/%m/%Y")
length(flora2$DateFirst[flora2$DateFirst == "1970-01-01"])
## confirmed
flora2$DateLast <- as.Date(flora2$DateLast, format = "%d/%m/%Y")
length(flora2$DateLast[flora2$DateLast == "1970-01-01"])
## 0 records of 1970-01-01

# I took a look at these dates to see why the starting and ending dates don't match. Many records(all?) with the start date 1970-01-01 list an end date in 2011. This was a random selection so there could be further, similar issues. This could also be an error resulting from date format conversion. Let's look at the original df
datecheck = flora %>% 
  filter(DateFirst == "01/01/1970") %>% 
  droplevels() %>% 
  st_as_sf(coords = c("Longitude_GDA94", "Latitude_GDA94"), 
           crs = 4283, agr = "identity")
## not a problem for the original data. All records with a start date of 1970-01-01 have an end date of either 30/06/2011 (2378 records) or 31/01/2000 (9 records). So what is going on here? Are these return plots or is the date of the survey unknown?
dplyr::filter(ccodes(), NAME %in% "Australia")
aus = getData("GADM", country = "AUS", level = 1) %>% 
  st_as_sf(aus) %>% 
  filter(NAME_1 == "New South Wales")
## these data shouldn't be committed but I don't know how to nest them in the data sample/ folder

# create interactive map of data points from 01-01-1970
# tmap_mode("view")
# qtm(aus) + qtm(datecheck)
## ok, the plots are not clustered

# Ok, I really don't know what the smallest denomination is within the unique identifiers. I need one that identifies unique survey & subplotID (-replicate) and one that identifies a location full stop. Survey and location date are contained in "ï..DatasetName", SightingKey, LocationKey, SurveyName, CensusKey, SiteNo, ReplicateNo and SubplotID
# let's take a look at each in turn, starting with counts.
sumflora = data.frame(types = c("total", "datasetname", "sightingkey", "locationkey", "surveyname", "censuskey", "siteno", "replicateno", "subplotid"), obs = c(1, 2, 3, 4, 5, 6, 7, 8, 9))
sumflora[1, 2] = nrow(flora)
a = 2
for (i in c(2, 3, 27, 37, 38, 40:42)){
  sumflora[a, 2] = length(unique(flora[,i]))
  a = a+1
}
sumflora

# unique(sightingkey) is the same length as the whole dataset so that's useless.
# locationkey is almost = siteno. Let me check the coordinates. Also check the time indices for there being different time points (could be tied to SiteNo duplicates)
sites = flora %>% 
  dplyr::select(LocationKey, SiteNo)
sites = unique(sites)
a = duplicated(sites$LocationKey)
dup = sites[a,]
dup
b = flora[flora$LocationKey %in% dup$LocationKey,] %>% 
  dplyr::select(LocationKey, SiteNo, Latitude_GDA94, Longitude_GDA94, DateFirst, DateLast)
## coordinates are all based more on LocationKey than SiteNo
## Date change accounts for at least one of the LocationKey duplicates, where the SiteNo changes with the date but the coordinates don't change.
### what I should probably do is just generate a unique key for coordinate + date combinations so it's obvious what I'm looking at.

# check that there are no other duplicates of lat/lon so that LocationKey is a unique ID of lat/lon coordinates. 
sumflora = data.frame(types = c("total", "datasetname", "sightingkey", "date1", "date2", "locationkey", "lat", "lon", "surveyname", "censuskey", "siteno", "replicateno", "subplotid"), obs = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13))
sumflora[1, 2] = nrow(flora)
a = 2
for (i in c(2, 3, 19, 20, 27, 29, 30, 37, 38, 40:42)){
  sumflora[a, 2] = length(unique(flora[,i]))
  a = a+1
}
sumflora
## LocationKey is longer than lat/lon so presumably there are duplicate coordinates for some LocationKey's
## There are more LocationKey's than dates, which makes sense. Do I need to know how many repeated measures there are? Should I grop them by 10m buffer?

# Check scientific names- are there cases where ScientificName and Assgn_ScientificName do not match?
nms = flora %>% 
  dplyr::select(ScientificName, CommonName, Assgn_ScientificName, Assgn_CommonName)
nms2 = data.frame(types = c("tot", names(nms)), obs = c(1, 2, 3, 4, 5))
nms2[1, 2] = nrow(nms)
a = 2
for (i in c(1:4)){
  nms2[a, 2] = length(unique(nms[,i]))
  a = a+1
}
nms2
## slightly different numbers of different names. 
# Let's check out the mis-matches
all(flora$ScientificName == flora$Assgn_ScientificName)
## returns an error because factor levels differ, which effectly gives the answer
mismatch = flora %>% 
  filter(as.character(ScientificName) != as.character(Assgn_ScientificName))
summary(mismatch)
## scrolled through enough to be confident that Assgn_ScientificName is the accepted/corrected version of whatever was entered in ScientificName

# # convert to simple feature, with crs of GDA94 and the attributes being identifications
# map1 = st_as_sf(flora, coords = c("Longitude_GDA94", "Latitude_GDA94"), 
#          crs = 4283, agr = "identity")



