
# refined code to make the tsibble every 15 minutes

Data_Halls_Residence <-read_rds("DHResidence.rds")


selected_units <- Data_Halls_Residence %>% filter(Source %in% c("B1 05","B2 15","B3 37", "B4 29", "BG 50"))

# Making sure that the timestamp is a R date-time object

selected_units$`Timestamp UTC` <- ymd_hms(selected_units$`Timestamp UTC`)


# Making it an tsibble object to see if the time gap is regular and to make implicit NAs as explicit

selected_units_tsibble <- as_tsibble(selected_units,key=id(Source),index=`Timestamp UTC`,tz="UTC")

Units_Data <-selected_units_tsibble %>% fill_na(, .full = TRUE)


first_day_of_month_wday <- function(dx) {
  day(dx) <- 1
  wday(dx)
}

# Making time indices

# Units_Data_m <- Units_Data %>%
#   mutate(
#          #Primary time units
#          month = month(`Timestamp UTC`, label = FALSE, abbr = TRUE), 
#          year =  year(`Timestamp UTC`),
#          min_proxy  = minute(`Timestamp UTC`)/15,
#          Hours =  hour(`Timestamp UTC`),
#          HlfHours = (Hours)*4 + (min_proxy+1),
#          
#          
#          # Week of the month and week of the year
#          
#          
#          # This adjustment needs to be done in order to get the correct week number otherwise if you have the 7th day of month on a Monday you will get 1 instead of 2, for example.
#          
#          wom = ceiling((day(`Timestamp UTC`) + first_day_of_month_wday(`Timestamp UTC`) - 1) / 7),
#          woy = week(`Timestamp UTC`),
#          
#          # day of the week, day of the month and day of the year
#          
#          dow = wday(`Timestamp UTC`, label=FALSE, abbr=TRUE,
#                      week_start=1), 
#          dom = day(`Timestamp UTC`),
#          doy = yday(`Timestamp UTC`),
#          
#          # Hour of the day, week, month and year
#          
#          how = (dow - 1) * 24 + Hours, 
#          hom = (dom - 1) * 24 + Hours,
#          hoy = (doy - 1) * 24 + Hours,
#          
#          # Half-Hour of the day, week, month and year
#          
#          hhow = (dow - 1) * 48 + HlfHours, 
#          hhom = (dom - 1) * 48 + HlfHours,
#          hhoy = (doy - 1) * 48 + HlfHours,
#       
#          Weekend=if_else(dow %in% c(6,7),1,0))

### renaming variables

Units_Data_m <- Units_Data %>%
  mutate(
    #Primary time units
    month = month(`Timestamp UTC`, label = FALSE, abbr = TRUE), 
    year_month = month(`Timestamp UTC`, label = FALSE, abbr = TRUE),
    year =  year(`Timestamp UTC`),
    min_proxy  = minute(`Timestamp UTC`)/15,
    week = week(`Timestamp UTC`),
    Hours =  hour(`Timestamp UTC`),
    HlfHours = (Hours)*4 + (min_proxy+1),
    HlfHours = (Hours)*4 + (min_proxy+1),
    day = day(`Timestamp UTC`),
    
    
    # Week of the month and week of the year
    
    
    # This adjustment needs to be done in order to get the correct week number otherwise if you have the 7th day of month on a Monday you will get 1 instead of 2, for example.
    
    month_week = ceiling((day(`Timestamp UTC`) + first_day_of_month_wday(`Timestamp UTC`) - 1) / 7),
    year_week = week(`Timestamp UTC`),
    
    # day of the week, day of the month and day of the year
    
    week_day = wday(`Timestamp UTC`, label=FALSE, abbr=TRUE,
               week_start=1), 
    month_day = day(`Timestamp UTC`),
    year_day = yday(`Timestamp UTC`),
    
    # Hour of the day, week, month and year
    
    week_hour = (week_day - 1) * 24 + Hours, 
    month_hour = (month_day - 1) * 24 + Hours,
    year_hour = (year_day - 1) * 24 + Hours,
    day_hour =  Hours,
    
    # Half-Hour of the day, week, month and year
    
    week_hh = (week_day - 1) * 48 + HlfHours, 
    month_hh = (month_day - 1) * 48 + HlfHours,
    year_hh = (year_day - 1) * 48 + HlfHours,
    day_hh =  HlfHours,
    hour_hh = if_else(week_day %in% c(0,1),1,2),
    Weekend=if_else(min_proxy %in% c(6,7),1,0))


Index_Set <- c("year","month","week","day","hour","hh")

nC2_results <- combn(Index_Set,2)
nC2_results

# Index_Set <- c("year","month","wom","woy","dow","dom","doy","how","hom","hoy","hhow","hhom","hhoy")
#Non SE as column names are called as variables


mapping_index <-  function(index1,index2)
{
  f <- paste0(index1,"_",index2)
  d <- Units_Data_m %>% group_by(.data[[index1]]) %>% mutate(count_d = length(unique(.data[[f]])))
  e <-ifelse(identical(max(d$count_d) ,min(d$count_d)),"Regular","Irregular")
  return(e)
}


data_tree_mat =matrix(0,ncol(nC2_results),3)

for(i in 1:ncol(nC2_results))
{ 
  index1 = nC2_results[1,i]
  index2 = nC2_results[2,i]
  r_index      = mapping_index(index1,index2)
  #data_tree_row <- 
  data_tree_mat[i,] =  c(index1,index2,r_index)
}

colnames(data_tree_mat) = c("level1","level2","Mapping")

data_tree_mat$pathString <- paste("Time_Granularities", 
                                  data_tree_mat$level1, 
                                  data_tree_mat$level2,
                            sep = "/")

h <- as.Node(data_tree_mat)
print(h, "Mapping")


# Problems setting colnames and putting dollars in data_tree_mat

