rm(list=ls())

library(RSQLite)
library(dplyr)
# library(dbplyr)
# library(replyr)

con <- dbConnect(RSQLite::SQLite(), "DHResidence.db")
energy <- tbl(con, 'energy')

# If data needs to be collected for a single source

b105 <- energy %>%
  filter(source == 'B1 05') %>%
  collect()


# Reconfirming that each source contains the same number of rows now

rec.by.source <- energy %>%
  group_by(source) %>%
  summarize(count = n())
