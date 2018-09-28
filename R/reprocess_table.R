rm(list=ls())

library(RSQLite)
library(dplyr)
# library(dbplyr)
# library(replyr)

con <- dbConnect(RSQLite::SQLite(), "DHResidence.db")
energy <- tbl(con, 'energy')

b105 <- energy %>%
  filter(source == 'B1 05') %>%
  collect()

rec.by.source <- energy %>%
  group_by(source) %>%
  summarize(count = n())
