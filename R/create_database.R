rm(list=ls())

library(RSQLite)
library(dplyr)

data_file <- "NRAS Treatment Group Data Export_2018-05-31-15-57-41.csv"

df <- read_csv(data_file,
               col_types = cols(
                 `Timestamp UTC` = col_datetime(format = ""),
                 Timestamp = col_datetime(format = ""),
                 Value = col_double(),
                 Source = col_character(),
                 Measurement = col_character(),
                 Unit = col_character()
               )) %>%
  rename(
    time.utc = `Timestamp UTC`,
    time.local = `Timestamp`,
    source = Source,
    measurement = Measurement,
    unit = Unit,
    value = Value
  ) %>%
  mutate(
    time.utc = as.numeric(strftime(time.utc, '%Y%m%d%H%M')),
    time.local = as.numeric(strftime(time.local, '%Y%m%d%H%M')),
    source = factor(source)
  ) 

date.range <- range(df$time.utc)
date.range.POSIXct <- strptime(as.character(date.range), '%Y%m%d%H%M')

reference.times <- data_frame(
  time.utc = seq(
    from=as.POSIXct(date.range.POSIXct[1], tz='UTC'),
    to=as.POSIXct(date.range.POSIXct[2], tz='UTC'),
    by='15 min'
  )) %>%
  mutate(
    timeid = as.numeric(strftime(time.utc, '%Y%m%d%H%M')),
    dateid = as.numeric(strftime(time.utc, '%Y%m%d')),
    dayname = strftime(time.utc, '%A')
  )

df.uniform <- expand.grid(time=reference.times$timeid,
                        source=unique(df$source)) %>%
  left_join(df, by=c('time'='time.utc', 'source'))

con <- dbConnect(RSQLite::SQLite(), "DHResidence.db")
copy_to(con, df.uniform, name='energy', overwrite=TRUE, temporary = FALSE)
dbDisconnect(con)

