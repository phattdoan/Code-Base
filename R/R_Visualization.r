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
## Spatial mapping with ggmap
slc.map = get_map('salt lake', scale = 2)
ggmap(slc.map, extent = 'device')  +
geom_point(data=centers.geo, aes(x = lon, y = lat),
            color="red") 