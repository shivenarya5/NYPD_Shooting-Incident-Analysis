# Load necessary libraries
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)

# Load the dataset
nypd_shootings <- read_csv("nypd-shootings (1).csv")

# Convert OCCUR_DATE to Date Format
nypd_shootings$OCCUR_DATE <- mdy(nypd_shootings$OCCUR_DATE)

# Function to calculate mode for categorical data
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# Handling missing values
# For numeric columns, replace NA with median
# For categorical columns, replace NA with mode
nypd_shootings <- nypd_shootings %>%
  mutate_if(is.numeric, ~ifelse(is.na(.), median(., na.rm = TRUE), .)) %>%
  mutate_if(is.factor, ~ifelse(is.na(.), as.factor(getmode(.)), .))

# Initial Data Analysis

# Summary statistics
summary(nypd_shootings)

# Number of shootings per year
nypd_shootings %>%
  mutate(Year = year(OCCUR_DATE)) %>%
  count(Year) %>%
  arrange(Year)

# Number of shootings per borough
nypd_shootings %>%
  count(BORO) %>%
  arrange(desc(n))




