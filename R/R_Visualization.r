library(Cairo) # export file to png
png(filename="16clinicsMap.png", 
    type="cairo",
    units="in", 
    width=10, 
    height=12, 
    pointsize=12, 
    res=96)

`imagecode`

dev.off()
-----------------------------------------------------------------------------------------------
## Looping to display all maps
## Disease Indicators - Density Map
```{r}
for (i in 16:35){
  temp = subset(members.15.over65, members.15.over65[i]== 1)
  count = sum(temp[i])
  
  temp.density.overlay =  stat_density_2d(data = temp, 
                                           aes(x = Longitude, y = Latitude, 
                                               size = ..level..,
                                               alpha = ..level..),
                                           bins = 10, geom = "polygon")
  title = paste("Density of Member with", colnames(temp)[i], sep = " ")
  
  subtitle = paste("Members with condition:", toString(count), sep = " ")
  
  print(ggmap(central.map, extent = 'device', legend = "topright") +
     temp.density.overlay + geom_point(data=centers, aes(x=lon, y=lat, color=name.cleaned), size=2, alpha=0.5) +
    labs(title=title,
          subtitle=subtitle) +
    theme(legend.position="none") +
    theme(plot.title=element_text(size=15, hjust=0.5, face="bold", 
                                  colour="blue", vjust=-1)) +
    theme(plot.subtitle=element_text(size=10, hjust=0.5, face="italic", color="black")))
}

rm(temp)
rm(temp.density.overlay)
```

## Charles Comorbidity - Diseases Density Map
```{r}
for (i in 38:38){
  temp = members.15.over65
  head(temp)
  temp[i] <- ifelse(temp[i] > 0,1,0)
  head(temp[i])
  temp = subset(members.15.over65, members.15.over65[i]== 1)
  head(temp[i])
  # members.15.over65[members.15.over65$MORB_OBESE_IND == 1]
  
  temp.density.overlay =  stat_density_2d(data = temp, 
                                           aes(x = Longitude, y = Latitude, 
                                               size = ..level..,
                                               alpha = ..level..),
                                           bins = 10, geom = "polygon")
  title = paste("Density of Member with", colnames(temp)[i], sep = " ")
  
  subtitle = paste("Members with condition:", toString(count), sep = " ")
  
  print(ggmap(central.map, extent = 'device', legend = "topright") +
     temp.density.overlay + geom_point(data=centers, aes(x=lon, y=lat, color=name.cleaned), size=2, alpha=0.5) +
    ggtitle(title) +
    theme(legend.position="none"))
}

rm(temp)
rm(temp.density.overlay)
```

-----------------------------------------------------------------------------------------------
## ggmap with density plot
shape.list.mz.midvale.ft = fortify(shape.list.mz[shape.list.mz$Name == "Midvale Senior Center" & shape.list.mz$contour==15,])

#geom_polygon only with SpatialPolygonDataFrame
#fortify reframe the SpatialDataFrame
ggmap(central.map, extent = 'device', legend = "topright") +
  members.15.over65.density.overlay + scale_fill_gradient(low = "blue", high = "red") +
  geom_path(data=shape.list.mz.midvale.ft, aes(x=long, y=lat, group = group)) + 
  geom_point(data=centers, aes(x=lon, y=lat), color = "black", size=2, alpha=0.5, fill = NA) + 
  labs(title = "Midvale's 15 min Contour",
       subtitle = "Medicare Member Density across the Salt Lake Valley ") + 
  theme(plot.title=element_text(size=15, hjust=1, face="bold", 
                                  colour="blue", vjust=-2), 
        plot.subtitle=element_text(size=10, hjust=1, face="italic", 
                                  colour="black", vjust=-1),
        legend.position="none")

-----------------------------------------------------------------------------------------------
## Pareto Chart w/ qcc library
library(qcc)
defect <- c(80, 27, 66, 94, 33)
names(defect) <- c("price code", "schedule date", "supplier code", "contact num.", "part num.")
pareto.chart(defect, ylab = "Error frequency", col=heat.colors(length(defect)))

-----------------------------------------------------------------------------------------------
## Pareto Chart w/ ggplot2
library(ggplot2)

counts  <- c(80, 27, 66, 94, 33)
defects <- c("price code", "schedule date", "supplier code", "contact num.", "part num.")

dat <- data.frame(
  count = counts,
  defect = defects,
  stringsAsFactors=FALSE
)

dat <- dat[order(dat$count, decreasing=TRUE), ]
dat$defect <- factor(dat$defect, levels=dat$defect)
dat$cum <- cumsum(dat$count)
dat

ggplot(dat, aes(x=defect)) +
  geom_bar(aes(y=count), fill="blue", stat="identity") +
  geom_point(aes(y=cum)) +
  geom_path(aes(y=cum, group=1))

-----------------------------------------------------------------------------------------------
## Loop to plot
for (i in 3:length(clinics.diseases.pcnt)){
  title = paste("Percentage of Members with", colnames(clinics.diseases.pcnt[i]),
              sep =" ")
  print(ggplot(data=clinics.diseases.pcnt, aes(x= Clinic, 
                                               y= clinics.diseases.pcnt[[i]], 
                                               color = Clinic)) +
  geom_bar(stat="identity") + coord_flip() +
  ggtitle(title) +
  theme(legend.position="none") +
  labs(y= colnames(clinics.diseases.pcnt[i])))
}

-----------------------------------------------------------------------------------------------
## line histogram w/ ggplot for multiple clinics
ggplot(data = m15.trsf, aes(CC_WEIGHT_VAL, ..density.., colour = Clinic)) + 
  geom_freqpoly(binwidth = 1) + 
  labs(title="Histogram for CC_DISEASE_CNT") +
  labs(x= "CC_DISEASE_CNT", y="Frequency")

-----------------------------------------------------------------------------------------------
## boxplot
ggplot(m15.trsf, aes(Clinic, CC_DISEASE_CNT, color = Clinic)) + geom_boxplot() +
  theme(legend.position="none", axis.text.x = element_text(angle = 90,hjust = 1)) +
  ylab("CC_DISEASE_CNT") + xlab("Clinics")

-----------------------------------------------------------------------------------------------
## Spatial mapping with ggmap
slc.map = get_map('salt lake', scale = 2)
ggmap(slc.map, extent = 'device')  +
geom_point(data=centers.geo, aes(x = lon, y = lat),
            color="red") 