# Google Capstone Project: Cyclistic Review

## Overview
This is my first data analysis project using Power Query, R programming, and Tableau. The analysis focuses on understanding bike usage patterns and trends within Cyclistic's customer base, particularly the differences between casual riders and annual members.

## Purpose
The purpose of this analysis is to uncover trends within the customer base and understand the differences between casual riders and annual members. The goal is to provide three actionable decisions for the marketing team.

## Data Cleaning and Limitations
A key limitation was the inability to calculate the exact distance traveled for each trip due to having only start and end station data. Extensive data cleansing was performed, removing 1.6 million observations, including 54,000 trips under 1 minute.

## Key Findings

### Total Rides and Average Duration
- **Total Rides**: Over 4 million
- **Average Duration**: 12 minutes for members, 23 minutes for casual riders

### Bike Options Used
Classic bikes are the preferred choice for both casual and member riders, with members favoring them slightly more.

### Top 10 Start and End Locations
#### Members
- **Start Locations**: Top 10 make up 7.36% of all member rides.
- **End Locations**: Top 10 account for 7.44% of rides.
- **Insight**: Frequent activity around business districts and residential areas.

#### Casual Riders
- **Start Locations**: Top 10 make up 14.56% of all casual rides.
- **End Locations**: Top 10 account for 14.83% of rides.
- **Insight**: Preference for tourist spots and scenic areas.

### Ride Density
#### Weekdays
- **Members**: Peaks at 8am and 5pm.
- **Casuals**: Peak at 5pm with steady usage throughout the day.

#### Weekends
- **Members**: Peaks from 12pm-4pm with a notable peak at 8am.
- **Casuals**: Peaks from 12pm-4pm.

### Overall Ride Patterns
- **Weekdays**: 70.5% of total rides, with members accounting for 69% and casual riders 31%.
- **Weekends**: 29.5% of the rides, with members accounting for 55% and casual riders 45%.
- **Saturday**: Highest count of rides.

### Seasonal Trends
Both casual and member riders see a significant drop in bike usage during winter, with casual riders dropping by 86% and members by 64%.

### Impact of Special Events
Special biking events did not significantly impact bike usage, even when hosted by local cycling clubs.

## Recommendations

### Partnerships and Sponsorships with Local Clubs/Events
Engaging users through community activities and events can strengthen their commitment. Offering discounts to club/event members can further encourage engagement.

### App Adoption
Introducing an app that tracks rides, accomplishments, and community rankings can enhance user engagement and long-term usage.

### Distance Tracking
Implementing distance tracking and displaying total distance covered by all riders on the company website can highlight community effort and provide insights into customer behavior.

## Conclusion
Partnering with local clubs, implementing an app, and distance tracking can help Cyclistic grow annual memberships through customer satisfaction and targeted marketing.

Thank you for reviewing this analysis.

Check out my Tableau dashboard for an interactive view of the data [here](https://public.tableau.com/views/CyclisticReview/CyclisticReview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link).
