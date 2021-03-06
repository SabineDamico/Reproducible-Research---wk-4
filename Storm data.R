## Public health and economic impacts from storms and other severe weather patterns

# This analysis examines fatalities and injuries and economic damages resulting # from storms and other 
#severe weather patterns in the USA since 1950. The starting point for the analysis is the Storm dataset 
# from U.S. National Oceanic and Atmospheric Administration's (NOAA) with subsequent transformation of 
# the data to examine two fundamental questions:
# 1. Across the United States, which types of events (as indicated in the EVTYPE variable) are most harmful with respect 
# to population health?
# 2. Across the United States, which types of events have the greatest economic consequences?
# I found that Tornados were the leading cause of injuries and fatalities whereas Flood events were the
# leading cause of property and crop damage. 
# Tornadoes caused 31,893 death and injuries whereas floods caused property and crop damage in access of 
# $140B in damage.


## Data processing

# The U.S. National Oceanic and Atmospheric Administration's (NOAA) is found at this site:
FileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"

# The file is downloaded:
download.file(FileURL, destfile = "./R/data/FStormdata.csv.bz2")

# The downloaded file is being read:
Stormdata <- read.csv("./R/data/FStormdata.csv.bz2")

# Transform into data.frame
Stormdata <-data.frame(Stormdata)

# Examine data
summary(Stormdata)
head((Stormdata))
str(Stormdata$PROPDMGEXP)


# Install packages
library(dplyr)
library(ggplot2)


## Examine what type of events have a significant impact on injuries and fatalities
PopulationImpact <- select(Stormdata,EVTYPE,FATALITIES,INJURIES) %>%
        group_by(EVTYPE)
PopulationImpact <- aggregate(FATALITIES ~ EVTYPE + INJURIES, PopulationImpact, sum)
arrange(PopulationImpact, EVTYPE) %>% 
        group_by(EVTYPE) %>%
        tally()
TotalIMP <- PopulationImpact$INJURIES + PopulationImpact$FATALITIES
TotalPopImpact <- cbind(PopulationImpact,TotalIMP)
TotalPopImpact1 <- arrange(TotalPopImpact,EVTYPE)
TotalPopImpact2 <- group_by(TotalPopImpact1,EVTYPE)
TotalPopImpact3 <- aggregate(TotalIMP ~ EVTYPE, TotalPopImpact2, sum)
TotalPopImpact4 <- filter(TotalPopImpact3, TotalIMP > 1000)
TotalPopImpact5 <- arrange(TotalPopImpact4,desc(TotalIMP))
##Results
par(las=2)
par(mar=c(4,10,4,2))
barplot(TotalPopImpact5$TotalIMP, main="Top Fatalities & Injuries by Event type", horiz=TRUE,
        names.arg = TotalPopImpact5$EVTYPE, cex.names = 0.8, border = "black", col = "coral")
text(18000,0.8,"Tornadoes cause the greatest # of injuries and fatalities")
# Tornadoes are the leading cause of injuries and fatalities: 31,893 cases since 1950                                                                                                 

## Examine what events have the greatest economic impact by looking at the estimated property damage
PropCropDmg <- select(Stormdata, EVTYPE,CROPDMG,PROPDMG,CROPDMGEXP,PROPDMGEXP) %>%
        group_by(EVTYPE) 
summary(PropCropDmg$CROPDMGEXP)
summary(PropCropDmg$PROPDMGEXP)

PropCropDmg$PROPDMGEXP <- sub("[-?+012345678]", "1", PropCropDmg$PROPDMGEXP, ignore.case = TRUE)
PropCropDmg$PROPDMGEXP <- sub("^$", "1", PropCropDmg$PROPDMGEXP, ignore.case = TRUE)
PropCropDmg$PROPDMGEXP <- sub("K", "1000", PropCropDmg$PROPDMGEXP, ignore.case = TRUE)
PropCropDmg$PROPDMGEXP <- sub("M", "1000000", PropCropDmg$PROPDMGEXP, ignore.case = TRUE)
PropCropDmg$PROPDMGEXP <- sub("B", "1000000000", PropCropDmg$PROPDMGEXP, ignore.case = TRUE)
PropCropDmg$PROPDMGEXP <- sub("H", "100", PropCropDmg$PROPDMGEXP, ignore.case = TRUE)
PropCropDmg$TotalPropdmg <- PropCropDmg$PROPDMG*as.numeric(PropCropDmg$PROPDMGEXP)


PropCropDmg$CROPDMGEXP <- sub("[?02]", "1", PropCropDmg$CROPDMGEXP, ignore.case = TRUE)
PropCropDmg$CROPDMGEXP <- sub("^$", "1", PropCropDmg$CROPDMGEXP, ignore.case = TRUE)
PropCropDmg$CROPDMGEXP <- sub("^K$", "1000", PropCropDmg$CROPDMGEXP, ignore.case = TRUE)
PropCropDmg$CROPDMGEXP <- sub("^M$", "1000000", PropCropDmg$CROPDMGEXP, ignore.case = TRUE)
PropCropDmg$CROPDMGEXP <- sub("^B$", "1000000000", PropCropDmg$CROPDMGEXP, ignore.case = TRUE)
PropCropDmg$TotalCropdmg <- PropCropDmg$CROPDMG*as.numeric(PropCropDmg$CROPDMGEXP)
PropCropDmg$TotalDMG <- PropCropDmg$TotalCropdmg+PropCropDmg$TotalPropdmg

PropCropDmg <- select(PropCropDmg,EVTYPE,TotalDMG) %>%
        arrange(PropCropDmg$EVTYPE)
PropCropDmg1 <- data.frame(PropCropDmg)  
PropCropDmg2 <- aggregate(TotalDMG ~ EVTYPE, PropCropDmg1,sum)
PropCropDmg3 <- filter(PropCropDmg2, TotalDMG > 5000000000)
PropCropDmg4 <- arrange(PropCropDmg3,desc(TotalDMG))
PropCropDmg4$TotalDMG <- PropCropDmg4$TotalDMG/1000000000
##Results
par(las=2)
par(mar=c(4,10,4,4))
barplot(PropCropDmg4$TotalDMG, main="Property and Crop Damage by Event type in Billions", horiz=TRUE,
        names.arg = PropCropDmg4$EVTYPE, cex.names = 0.8, border = "black", col = "coral")
text(75,0.8,"Flood events cause the greatest # of property and crop damage")
#Floods are the leading cause of property and crop damage with over $140B in damages.

