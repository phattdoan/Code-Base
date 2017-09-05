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