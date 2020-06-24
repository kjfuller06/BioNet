## there's a variable I haven't examined I might want to include, which is NumberIndividuals

# assign library path
.libPaths("C:/Users/90946112/R/win-library/3.6.2")
library(tidyverse)
library(sf)

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
  select(DateFirst, DateLast, LocationKey, Latitude_GDA94, Longitude_GDA94, Accuracy, Stratum, GrowthForm, CoverScore, AbundanceScore, PercentCover, LowerHeight, UpperHeight) %>% 
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
  filter(DateFirst == "01/01/1970")
summary(droplevels(datecheck))
## not a problem for the original data. All records with a start date of 1970-01-01 have an end date of either 30/06/2011 (2378 records) or 31/01/2000 (9 records)


# 7205 unique first dates
length(unique(flora2$DateFirst))
# 7206 unique last dates
length(unique(flora2$DateLast))
# 59438 unique plot locations
length(unique(flora2$LocationKey))

# check to see if all plots listed with the same LocationKey have identical lat/lon coordinates. If not, take a look at the points and qualitatively assess a few. Maybe throw out any coordinates before 1990 as well.

# 
# # convert to simple feature, with crs of GDA94 and the attributes being identifications
# map1 = st_as_sf(flora, coords = c("Longitude_GDA94", "Latitude_GDA94"), 
#          crs = 4283, agr = "identity")



