## Kahlil Wehmeyer - Office Of Strategic Initiatives
## Cleaning Script for Crime Reports


# Libraries ---------------------------------------------------------------
setwd("~/Documents/gainsville_exercise")

library(tidyverse)
library(janitor)
library(lubridate)
library(sf)

if (file.exists("data/cleaned_responses.csv")) {
 responses <- read_csv("data/cleaned_responses.csv") 
 areas <- read_sf("data/Gainesville Police Zones.geojson")
 stop("Not an error: Prepared data found on disk.\n Scrip continuing as should")
 
}

### Responses
# Import ------------------------------------------------------------------

responses <- read_sf('data/Crime_Responses.csv')

responses <- responses %>% clean_names()


areas <- read_sf("data/Gainesville Police Zones.geojson")

# Type Setting ------------------------------------------------------------

## ID
responses$id <- responses$id %>% as.integer()

## Incident Type
 cat("There are ", n_distinct(responses$incident_type), " unique incident types.")
# cat("\n Setting incident type to a categorical variable. \n")
responses$incident_type <- responses$incident_type %>% factor()

## Report Date
#cat("Report date is a ", typeof(responses$report_date), " type.\n")
#cat("\n Setting report type to a date variables. \n")
responses$report_date <- responses$report_date %>% parse_date_time(orders = "mdy HMS") %>% as_datetime()

## Offense date
responses$offense_date <- responses$offense_date %>% parse_date_time(orders = "mdy HMS") %>% as_datetime()

responses$offense_day_of_week <- factor(responses$offense_day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))
responses$report_day_of_week <- factor(responses$report_day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"))


# Filtering for 2015 -> 
responses <- responses %>% filter(year(offense_date) > 2014)

## City
cat("City has ", n_distinct(responses$city), " unique values.\n")
cat("\n Setting city to a categorical type. \n")
responses$city <- responses$city %>% factor()

## State
cat("State has ", n_distinct(responses$state), " unique values.\n")
cat("\n Removing state variable. It does not offer information.\n")
responses <- responses %>% select(-state)

# Coordinates
responses$longitude <- as.numeric(responses$longitude)
responses$latitude <- as.numeric(responses$latitude)
st_as_sf(responses, coords = c("longitude", "latitude"), crs = st_crs(areas), remove=FALSE) -> responses

# Determining which police zones incidents occured
st_join(responses, areas, join = st_within) -> responses
areas <- areas %>% as_tibble() 

# Removing extraneous variables
responses %>% select(-location, -shape_area, -shape_leng) -> responses

# Type setting districts, sectors ect,.
responses$district <- responses$district %>% factor()
responses$sector <- responses$sector %>% factor()
responses$label <- responses$label %>% factor()
responses$objectid <- responses$objectid %>% factor()

# Feature engineering
responses$in_district <- !is.na(responses$objectid)

# Writing cleaned data
responses %>% write_csv("data/cleaned_responses.csv")

areas <- read_sf("data/Gainesville Police Zones.geojson")

