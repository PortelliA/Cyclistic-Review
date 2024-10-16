setwd("C:/Users/alexa/OneDrive/Documents/combine capstone")
all_files <- list.files(pattern = "*.csv")

files <- all_files[all_files %in% c("202309-divvy-tripdata.csv", "202310-divvy-tripdata.csv", "202311-divvy-tripdata.csv", "202312-divvy-tripdata.csv", 
                                    "202401-divvy-tripdata.csv", "202402-divvy-tripdata.csv", "202403-divvy-tripdata.csv", "202404-divvy-tripdata.csv", 
                                    "202405-divvy-tripdata.csv", "202406-divvy-tripdata.csv", "202407-divvy-tripdata.csv", "202408-divvy-tripdata.csv")]
Cyclistic_data <- files %>% 
  lapply(read_csv) %>% 
  bind_rows()
rm(list = setdiff(ls(), "Cyclistic_data"))
#starts with 5,699,639 observation.


#Creating an area of which the chicago resides in. 
lat_min <- 41.6445  
lat_max <- 42.0230  
lng_min <- -87.9401 
lng_max <- -87.5237 

#A filter clause that will remove any rows that dont reside in the chicago area.
Cyclistic_data <- Cyclistic_data %>%
  filter(
    start_lat >= lat_min & start_lat <= lat_max &
      end_lat >= lat_min & end_lat <= lat_max &
      start_lng >= lng_min & start_lng <= lng_max &
      end_lng >= lng_min & end_lng <= lng_max)
#5,639,036 observations


#Clearing dates were the ended date is before starting.
Cyclistic_data <- Cyclistic_data %>%
  filter(
    ended_at > started_at & 
      as.Date(started_at) == as.Date(ended_at))


# 5,615,553 observations, having a check for column status.
str(Cyclistic_data)


#Another thing I noticed in excel was some of the start/end station names had some * at the end of some of the names. This will interfer with grouping later!
#So this function I'm not too experienced with, but what it is doing as I've interpreted is clearing * from the column, it replaces it with the "" which means nothing as this is a mutate function.
#but the & to the right inclosed by another ] is keeping "&" in the string which are in station names.
Cyclistic_data <- Cyclistic_data %>% 
  mutate(started_at = gsub("\\*", "", started_at)) %>% 
  mutate(ended_at = gsub("\\*", "", ended_at))


#the previous step changes the columns to chr , need to change them back.
Cyclistic_data <- Cyclistic_data %>% 
  mutate(started_at = as.POSIXct(started_at, format = "%Y-%m-%d %H:%M:%S")) %>% 
  mutate(ended_at = as.POSIXct(ended_at, format = "%Y-%m-%d %H:%M:%S"))


#Another mutate function that grabs the end time from the column and calculates the time different since start time. I had to search R for this one too.
Cyclistic_data <- Cyclistic_data %>% 
  mutate(duration = as.numeric(difftime(ended_at, started_at, units = "mins")))


#When cleaning in excel I noticed some blanks in columns for started at, ended at(small amount around 200) & alot in station name's(over a million).I have some rows in month of September of 2023 that ill remove soon
Cyclistic_data <- na.omit(Cyclistic_data)
# 4,149,404 obversations are left


#Checking to see if done correctly.
str(Cyclistic_data$duration)
summary(Cyclistic_data)




#This is an amazing package, With provided start/end latititude and longitude it can calculate the distance travelled!
Cyclistic_data <- Cyclistic_data %>% 
  rowwise() %>% 
  mutate(distance = distHaversine(c(start_lng, start_lat), c(end_lng, end_lat)))

#Previously made the result in meters, had to convert to km.
Cyclistic_data <- Cyclistic_data %>% 
  mutate(distance = distance / 1000)



#This is doing two things, creating a column for date exclusively from the started_at column, then using that newly created column to figure out the day of the week and create a column for that also.
Cyclistic_data <- Cyclistic_data %>% 
  mutate(date = as.Date(started_at),
         day = wday(date, label = TRUE, abbr = FALSE))

#I was having trouble getting the time out in 12-hour format, another one I had to look up. This extracts the time to look like 09AM, 05PM, 12PM, 11AM. They are stored as chr so ill need to order them later.
Cyclistic_data <- Cyclistic_data %>% 
  mutate(time = format(started_at, "%I%p"))

#I didn't like the leading 0 infront of say 05AM, this removes all leading 0 in the column.
Cyclistic_data$time <- sub("^0", "", Cyclistic_data$time)

#Using that date column I seperated earlier, remove the day to create a new column exclusively for month,
Cyclistic_data <- Cyclistic_data %>%
  mutate(month = format(date, "%Y-%m"))

Cyclistic_data <- Cyclistic_data %>%
  filter(month != "2023-08")

# 4,146,064 observations after removing those dates starting in 08


#Having a check of all the new edits.
head(Cyclistic_data$time)
head(Cyclistic_data$day)
head(Cyclistic_data$month)
summary(Cyclistic_data)
str(Cyclistic_data)

#All information has been extracted, removing these columns.
Cyclistic_data <- Cyclistic_data %>% 
  select(-started_at, -ended_at)


#During my time on excel I noticed alot of questionable figures. Creating tables for time  lengths below 3 minutes, and above 4 hours.

long_duration_data <- Cyclistic_data %>% 
  filter(duration > 240)

long_duration_summary <- long_duration_data %>%
  group_by(member_casual) %>%
  summarise(
    count = n(),
    mean_duration = mean(duration, na.rm = TRUE),
    max_duration = max(duration, na.rm = TRUE))

summary(long_duration_summary)

short_duration_data <- Cyclistic_data %>% 
  filter(duration < 3)

short_duration_summary <- short_duration_data %>% 
  group_by(member_casual) %>% 
  summarise(count = n(),
            mean_duration = mean(duration),
            max_duration = max(duration))

summary(short_duration_summary)



# 3,998 observations over 4hours in length.
# 289,273 observations under 3 minutes.




#Creating density graphs to deplay these results.
#You dont want to know how many copies of this plot I created with different variations, I went with simplicity and bolding the text after all the colour changing, vertical start/end lines & alpha line editing
ggplot(long_duration_data, aes(x = duration, fill = member_casual)) +
  geom_density(alpha = 0.5) +
  labs(title = "Ride Durations over 4 hours",
       subtitle = "3,998/4,146,064 observations are over 4 hours in the data set.",
       x = "Duration (minutes)") +
  theme_minimal() +
  theme(axis.title.y = element_blank(), 
        axis.text.y = element_blank(),  
        axis.ticks.y = element_blank(),
        plot.title = element_text(size = 20, face = "bold"),
        plot.subtitle = element_text(size = 16),  
        panel.grid = element_blank(),  
        legend.text = element_text(size = 14),  
        axis.title.x = element_text(size = 14),  
        axis.text.x = element_text(size = 12)) +  
  scale_x_continuous(breaks = c(240, seq(300, max(long_duration_data$duration), by = 60))) +
  guides(fill = guide_legend(title = NULL))




ggplot(short_duration_data, aes(x = duration, fill = member_casual)) +
  geom_density(alpha = 0.5) +
  labs(title = "Ride Durations under 3 minutes",
       subtitle = "289,273/4,146,064 observations are under 3 minutes in the data set.",
       x = "Duration (minutes)") +
  theme_minimal() +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_line(),
        plot.title = element_text(size = 20, face = "bold"),  
        plot.subtitle = element_text(size = 16), 
        legend.text = element_text(size = 14),  
        axis.title.x = element_text(size = 14), 
        axis.text.x = element_text(size = 12),  
        panel.grid = element_blank()) +  
  guides(fill = guide_legend(title = NULL))



#remove trips under 1 minute but I first want to capture this information, creating new table.
under_1min_duration <- Cyclistic_data %>% 
  filter(duration < 1)


#At this point this is my last filtering, so it goes from data, to review. Allowing me to keep the data file 1 step away from its review form.
Cyclistic_review <- Cyclistic_data %>% 
  filter(duration >= 1)



#after filtering out 1min durations count when down to 4,091,950.

#time to create some visualisations, remember how I said I converted time and day column's to <chr>, these below commands set it in order.

Cyclistic_review$time <- factor(Cyclistic_review$time, levels = c("1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM", "8AM", "9AM", "10AM", "11AM", "12PM", 
                                                                  "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM", "12AM" ))

Cyclistic_review$day <- factor(Cyclistic_review$day, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))


#I want to seperately attempt to analyse this data. Being the location of where trip begin and end including coordinates.
station_info <- Cyclistic_review %>%
  select(start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual)

# Create top ten end stations for casual members
top_end_stations_casual <- station_info %>%
  filter(member_casual == "casual") %>%
  group_by(end_station_name) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_head(n = 10)

# Create top ten end stations for members
top_end_stations_member <- station_info %>%
  filter(member_casual == "member") %>%
  group_by(end_station_name) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_head(n = 10)

# Create top ten start stations for casual members
top_start_stations_casual <- station_info %>%
  filter(member_casual == "casual") %>%
  group_by(start_station_name) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_head(n = 10)

# Create top ten start stations for members
top_start_stations_member <- station_info %>%
  filter(member_casual == "member") %>%
  group_by(start_station_name) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  slice_head(n = 10)



#Because I have that station table I wont need these, besides I have them still in Cyclistic_data table.
Cyclistic_review <- Cyclistic_review %>% 
  select(-start_station_id, -end_station_id, -start_station_name, -end_station_name, -ride_id, -start_lat, -start_lng, -end_lat, -end_lng)


#Checking.
summary(Cyclistic_data)
summary(Cyclistic_review)


#Creating tables for averages for duration,
avg_duration_full <- Cyclistic_review %>%
  group_by(member_casual, day, month) %>%
  summarise(avg_duration = mean(duration, na.rm = TRUE))




#While I have made my fair share of ggplots throughout the course, stat = "identity", position = "dodge" is something I also learnt from Equitable Equations.
#Because im working with averages divided between casual and members I didnt want it to be 100pct total together but seperate averages. Thats what the stat identity ensures.
#position = dodge ensures they dont appear ontop of each other but side by side.
#whether I use these graphs or visualisations from other platforms I dont know

ggplot(avg_duration_full, aes(x = month, y = avg_duration, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average Trip Duration(mins) by Month") +
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.title = element_blank()) +
  guides(fill = guide_legend(title = NULL))




ggplot(avg_duration_full, aes(x = day, y = avg_duration, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average Trip Duration(mins) by Day") +
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.title = element_blank()) +
  guides(fill = guide_legend(title = NULL))

Cyclistic_review <- Cyclistic_review %>%
  filter(month != "2023-08")



#created table to place in report, during the course we looked into the use of long and wide format. 
#I wanted to trial wide format as I've been working with alot of long data, I had to search this command of pivot_wider() as no prior expose.

avg_duration_table <- avg_duration_full %>% 
  select(member_casual, month, day, avg_duration) %>% 
  pivot_wider(names_from = month, values_from = avg_duration, names_prefix = "Month_") %>% 
  mutate(across(starts_with("Month_"), ~ paste0(round(.x, 2), " mins")))



#Time to save some files, so both these tables & station_info from earlier.
write.csv(station_info, "station_info.csv", row.names = FALSE)
write.csv(avg_duration_table, "average_duration_table.csv", row.names = FALSE)
write.csv(under_1min_duration, "under_1min_table.csv", row.names = FALSE)
write.csv(top_end_stations_casual, "top_end_stations_casual.csv", row.names = FALSE)
write.csv(top_end_stations_member, "top_end_stations_member.csv", row.names = FALSE)
write.csv(top_start_stations_casual, "top_start_stations_casual.csv", row.names = FALSE)
write.csv(top_start_stations_member, "top_start_stations_member.csv", row.names = FALSE)
write.csv(long_duration_data, "long_duration_data.csv", row.names = FALSE)
write.csv(short_duration_data, "short_duration_data.csv", row.names = FALSE)

#Creating table to help create a pie chart for count, not sure how it will turn out.
Counter <- Cyclistic_review %>% 
  group_by(member_casual) %>% 
  summarise(count = n()) 


ggplot(Counter, aes(x = 2, y = count, fill = member_casual)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  theme_minimal() +
  theme(axis.title = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        panel.grid = element_blank(),
        legend.title = element_blank()) +
  labs(title = "Count of trips: Member vs Casual",
       subtitle = "Members = 65% of the count\nCasuals = 35% of the count\nTotal count = 4,091,950") +
  geom_text(aes(label = scales::comma(count)), position = position_stack(vjust = 0.5))


#I want to observe is trips per day by the time of day.
#I had to look into how to do this step, within this table I wanted to have the count & percentage per day, the groups = 'drop' helps hold the percentage to the day and not the whole table.
group_by_day <- Cyclistic_review %>% 
  group_by(day, time) %>%
  summarise(count = n(), .groups = 'drop') %>% 
  group_by(day) %>% 
  mutate(percentage = count / sum(count) * 100)


monthly_counts <- Cyclistic_review %>% 
  group_by(month, member_casual) %>% 
  summarise(count = n(), .groups = 'drop')


bike_type_counts <- Cyclistic_review %>% 
  group_by(rideable_type, member_casual) %>% 
  summarise(count = n(), .groups = 'drop')



write.csv(group_by_day, "counts_by_time_by_day.csv", row.names = FALSE)
write.csv(monthly_counts, "monthly_counts.csv", row.names = FALSE)
write.csv(bike_type_counts, "bike_type_counts.csv", row.names = FALSE)
write.csv(Counter, "count_of_trips.csv", row.names = FALSE)
write.csv(Cyclistic_data, "Cyclistic_data.csv", row.names = FALSE)
write.csv(Cyclistic_review, "Cyclistic_review.csv", row.names = FALSE)


