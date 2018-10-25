library(dplyr)
library(readr)
library(tidyverse)
library(tsibble)
library(skimr)
library(visdat)

                     ##****Data_Halls_Residence****##

#Data_Halls_Residence <- read_csv("NRAS Treatment Group Data Export_2018-05-31-15-57-41.csv")

#write_rds(Data_Halls_Residence,"DHResidence.rds")


Data_Halls_Residence <-read_rds("DHResidence.rds")


Data_Halls_Residence <- Data_Halls_Residence %>% select(-c(Measurement,Unit))


Residence_Spread <- Data_Halls_Residence %>% filter(Source=="B1 05") %>% spread(Timestamp,Value)



Residence_Spread <- Data_Halls_Residence  %>% spread(Timestamp,Value)


# Date Range: 06:30 hours of April 13, 2018 to 05:45 hours of May 31, 2018

length(unique(Data_Halls_Residence$Source))

# 73 number of living units

nobs <- Data_Halls_Residence %>%  group_by(Source) %>% summarize(Group_obs = n()) 

range(nobs$Group_obs)




#Every unit does not have data for same time horizon

glimpse(Data_Halls_Residence)

skim(Data_Halls_Residence) # advanced form of function "str"


vis_dat(Data_Halls_Residence,warn_large_data =FALSE)

vis_miss(Data_Halls_Residence, warn_large_data =FALSE)

##converting the data to tsibble to convert implicit missing values to explicit missing values 

Data_Halls_Residence <- as_tsibble(Data_Halls_Residence,key=id(Source),index=`Timestamp UTC`,tz="UTC")


Data_Halls_Residence %>% fill_na(Data_Halls_Residence, .full = TRUE)
                     ##****Data_NMI****##

Data_NMI <- read_csv("report (6).csv")

str(Data_NMI)

# Date Range: 00:15 hours of July 20, 2016 to 00:00 hours of September 21, 2018

dim((Data_NMI))[1]

# 76128 observations
#