rm(list=ls())

library(RSQLite)
library(dplyr)
library(dbplyr)
library(replyr)

con <- dbConnect(RSQLite::SQLite(), "DHResidence.db")
energy <- tbl(con, 'energy')

devtools::install_github("tidyverse/dbplyr", ref = devtools::github_pull(72))

energy_spread <- energy %>% select(Timestamp,Source,Value) %>% 
  spread(key=Timestamp,value=Value)
 
energy_gather <- energy_spread %>%
  gather(Timestamp,Demand,-Source)



energy_gather <- energy_spread %>%
  build_pivot_control(columnToTakeKeysFrom= 'TimeStamp_All', 
                      columnToTakeValuesFrom= 'Demand')