library(RSQLite)
library(dplyr)

df <- read_rds("DHResidence.rds")

con <- dbConnect(RSQLite::SQLite(), "DHResidence.db")
copy_to(con, df, name='energy', overwrite=TRUE, temporary = FALSE)
dbDisconnect(con)
