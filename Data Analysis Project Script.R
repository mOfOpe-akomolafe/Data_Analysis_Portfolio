# This project displays a conceptual understanding of R studio fundamentals. 
# Utilizing R libraries and their functions to manipulate data extracted from a Boston University SQL server in order to present insights on a business case study. 
 

# Installing library packages.

install.packages("odbc")
install.packages("DBI")
install.packages("tidyverse")
install.packages("lubridate")
install.packages("magrittr")
install.packages("dplyr")
install.packages("ggplot2")

# R library packages are loaded.

library(odbc)
library(DBI)
library(tidyverse)
library(lubridate)
library(magrittr)
library(dplyr)
library(ggplot2)

# Connecting to BU SQL Server to access 

con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = 'metsql.database.windows.net',
                 Database = 'NYC Real Estate',
                 uid = "met_student",
                 pwd = "Stdnt_dbcourses!#",
                 Port = 1433)

#Tables are re-assigned as the information is extracted from SQL server.

AllData_Joined<- NYC_TRANSACTION_DATA %>%
  left_join(BUILDING_CLASS, by=c("BUILDING_CLASS_FINAL_ROLL"="X.BUILDING_CODE_ID"))%>%
  left_join(NEIGHBORHOOD, by=c("NEIGHBORHOOD_ID"="NEIGHBORHOOD_ID"))

AllData_Joined_Selected<- NYC_TRANSACTION_DATA %>%
  left_join(BUILDING_CLASS, by=c("BUILDING_CLASS_FINAL_ROLL"="X.BUILDING_CODE_ID"))%>%
  left_join(NEIGHBORHOOD, by=c("NEIGHBORHOOD_ID"="NEIGHBORHOOD_ID"))%>%
  filter(SALE_PRICE>100000, GROSS_SQUARE_FEET>350)%>%
  select(NEIGHBORHOOD_ID,RESIDENTIAL_UNITS)

# Summary (AllData_Joined)

# Determining the average price of 1 square foot of residential (commercial) real estate in Astoria by year

Astoria<- AllData_Joined %>%
  mutate(SaleYear=year(SALE_DATE)) %>%
  filter(NEIGHBORHOOD_NAME=="ASTORIA",TYPE== "COMMERCIAL") %>%
  group_by(SaleYear) %>%
  summarise(TotalSales=sum(SALE_PRICE),TotalSqft=sum(GROSS_SQUARE_FEET), Avg=TotalSales/TotalSqft)

summary(Astoria)
View(Astoria)

# Filtering data further to ensure results are not skewed by defining filter parameters. 

CLEAN_ASTORIA<- AllData_Joined %>%
  mutate(SaleYear=year(SALE_DATE)) %>%
  filter(NEIGHBORHOOD_NAME=="ASTORIA",TYPE== "COMMERCIAL",SALE_PRICE>100000, GROSS_SQUARE_FEET>350) %>%
  group_by(SaleYear) %>%
  summarise(TotalSales=sum(SALE_PRICE),TotalSqft=sum(GROSS_SQUARE_FEET), Avg=TotalSales/TotalSqft)

summary(CLEAN_ASTORIA)
View(CLEAN_ASTORIA)

# Comparison of Astoria with Bayside another neighbourhood in the borough of Queens.

BAYSIDE<- AllData_Joined %>%
  mutate(SaleYear=year(SALE_DATE)) %>%
  filter(NEIGHBORHOOD_NAME=="BAYSIDE",TYPE== "COMMERCIAL",SALE_PRICE>100000, GROSS_SQUARE_FEET>350) %>%
  group_by(SaleYear) %>%
  summarise(TotalSales=sum(SALE_PRICE),TotalSqft=sum(GROSS_SQUARE_FEET), Avg=TotalSales/TotalSqft)

summary(BAYSIDE)
View(BAYSIDE)

# Visual comparison of Astoria and Bayside. 

# ggplot() Mean_Price_Per_Square_Foot & Average_Price 

ggplot()+
  geom_line(data=CLEAN_ASTORIA,size=1, aes(x=SaleYear, y=Avg, color="blue"))+
  geom_line(data=Astoria,size=1, aes(x=SaleYear, y=Avg, color="red"))+
  scale_color_identity(name="Neighborhood", breaks= c("blue","red"), labels=c("CLEAN_ASTORIA","ASTORIA"), guide = "legend")+
  scale_x_continuous(breaks = seq(2003,2022, by = 3))
scale_y_continuous(breaks = seq(0, 6000, by = 500))


ggplot()+
  geom_line(data=CLEAN_ASTORIA,size=1, aes(x=SaleYear, y=Avg, color="blue"))+
  geom_line(data=BAYSIDE,size=1, aes(x=SaleYear, y=Avg, color="green"))+
  scale_color_identity(name="Neighborhood", breaks= c("blue","green"), labels=c("CLEAN_ASTORIA","BAYSIDE"), guide = "legend")+
  scale_x_continuous(breaks = seq(2003,2021, by = 2))
scale_y_continuous(breaks = seq(0, 6000, by = 300))
