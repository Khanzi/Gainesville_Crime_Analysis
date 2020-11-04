## Kahlil Wehmeyer - Office Of Strategic Initiatives
## Cleaning Script for Crime Reports


# Libraries ---------------------------------------------------------------
setwd("~/Documents/gainsville_exercise")

library(tidyverse)
library(janitor)
library(lubridate)


# Import ------------------------------------------------------------------

responses <- read_csv('data/Crime_Responses.csv')

responses <- responses %>% clean_names()



# Type Setting ------------------------------------------------------------

## Incident Type
# cat("There are ", n_distinct(responses$incident_type), " unique incident types.")
# cat("\n Setting incident type to a categorical variable. \n")
responses$incident_type <- responses$incident_type %>% factor()

## Report Date
#cat("Report date is a ", typeof(responses$report_date), " type.\n")
#cat("\n Setting report type to a date variables. \n")
responses$report_date <- responses$report_date %>% parse_date_time(orders = "mdy HMS") %>% as_datetime()

## Offense date
responses$offense_date <- responses$offense_date %>% parse_date_time(orders = "mdy HMS") %>% as_datetime()

## City
cat("City has ", n_distinct(responses$city), " unique values.\n")
cat("\n Setting city to a categorical type. \n")
responses$city <- responses$city %>% factor()

## State
cat("State has ", n_distinct(responses$state), " unique values.\n")
cat("\n Removing state variable. It does not offer information.\n")
responses <- responses %>% select(-state)

# Point

cat("Removing location. Extraneous variable. \n")
responses <- responses %>% select(-location)

## Completed Cleaning Responses