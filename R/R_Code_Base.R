



--------------------------------------------------------------------------------------------------------
Democrat:
1, 2, 3
Ex, center, slight

Republican
5, 6, 7
slight, ex, center

Dem_pol_raw = S_fil[which(S_fil$libcpre_combined == 5 | S_fil$libcpre_combined == 6 | S_fil$libcpre_combined == 7), c("libcpo_combined","libcpre_combined")]

Dem_pol_raw$Dem_polshift = Dem_pol_raw$libcpo_combined - Dem_pol_raw$libcpre_combined

summary(Dem_pol_raw$Dem_polshift)

hist(Dem_pol_raw$Dem_polshift)

--------------------------------------------------------------------------------------------------------
The sampling method for each sample is simple random sampling.
The samples are independent.
Each population is at least 20 times larger than its respective sample.
The sampling distribution is approximately normal, which is generally the case if any of the following conditions apply.

The population distribution is normal.
The population data are symmetric, unimodal, without outliers, and the sample size is 15 or less.
The population data are slightly skewed, unimodal, without outliers, and the sample size is 16 to 40.
The sample size is greater than 40, without outliers.

--------------------------------------------------------------------------------------------------------
S$libcpo_combined <- ifelse((S$libcpo_self == "-2. Haven't thought much {do not probe}" | S$libcpo_self == "-6. Not asked, unit nonresponse (no post-election interview)" | S$libcpo_self == "-7. Deleted due to partial (post-election) interview" | S$libcpo_self == "-8. Don't know" | S$libcpo_self == "-9. Refused"), ifelse (S$libcpo_selfch == "1. Liberal", 2, ifelse (S$libcpo_selfch == "2. Conservative", 6, ifelse(S$libcpo_selfch == "3. Moderate {VOL}", 4, -1))), ifelse(S$libcpo_self ==  "4. Moderate; middle of the road", ifelse (S$libcpo_selfch == "1. Liberal", 2, ifelse (S$libcpo_selfch == "2. Conservative", 6, 4)), as.numeric(S$libcpo_self) - 5))

S$libcpre_combined <- ifelse((S$libcpre_self == "-2. Haven't thought much about this" | S$libcpre_self == "-8. Don't know" | S$libcpre_self == "-9. Refused"), ifelse (S$libcpre_choose == "1. Liberal", 2, ifelse (S$libcpre_choose == "2. Conservative", 6, ifelse(S$libcpre_choose == "3. Moderate {VOL}", 4, -1))), ifelse(S$libcpre_self ==  "4. Moderate; middle of the road", ifelse (S$libcpre_choose == "1. Liberal", 2, ifelse (S$libcpre_choose == "2. Conservative", 6, 4)), as.numeric(S$libcpre_self) - 3))

LC = S[which(S$libcpo_combined != -1 & S$libcpre_combined != -1),c("X", "libcpre_self", "libcpre_choose", "libcpo_self", "libcpo_selfch", "libcpre_combined", "libcpo_combined")]


## subsetting the dataset to only relevant variables
```{r}
LC = S_filtered[c("X", "libcpre_self", "libcpre_choose", "libcpo_self", "libcpo_selfch", "libcpre_combined", "libcpo_combined")]

--------------------------------------------------------------------------------------------------------
fn_libcpre_comb <- function(dataset,col_name) {
  if (dataset$libcpre_self ==  "4. Moderate; middle of the road" | dataset$libcpre_self == "-2. Haven't thought much about this" |
  	  dataset$libcpre_self == "-8. Don't know" | dataset$libcpre_self == "-9. Refused") {
    if (dataset$libcpre_choose == "1. Liberal") {
    	dataset[col_name] = "2. Liberal"
    }
    else if (dataset$libcpre_choose == "2. Conservative"){
    	dataset[col_name] = "6. Conservative"
    }
    else
    	dataset[col_name] = "-1. Inapplicable"
  }
  else if (dataset$libcpre_self == "1. Extremely Liberal" | dataset$libcpre_self == "2. Liberal"
  	| dataset$libcpre_self == "3. Slightly Liberal"){
  	if {

  	}
  }
  dataset[col_name] = dataset$libcpre_self
  return(dataset)
}

fn_libcpre_comb(S,"libcpre_combined")

--------------------------------------------------------------------------------------------------------
fn_libcpre_comb <- function(dataset,col_name) {
  if (dataset$libcpre_self ==  "4. Moderate; middle of the road" | dataset$libcpre_self == "-2. Haven't thought much about this" |
  	  dataset$libcpre_self == "-8. Don't know" | dataset$libcpre_self == "-9. Refused") {
    if (dataset$libcpre_choose == "1. Liberal") {
    	dataset[col_name] = "2. Liberal"
    }
    else if (dataset$libcpre_choose == "2. Conservative"){
    	dataset[col_name] = "6. Conservative"
    }
    else
    	dataset[col_name] = "-1. Inapplicable"
  }
  else {
    dataset[col_name] = dataset$libcpre_self
  }
  return(dataset)
}

--------------------------------------------------------------------------------------------------------
fn_libcpre_comb <- function(se,ch) {
  if (se ==  "4. Moderate; middle of the road" | se == "-2. Haven't thought much about this" |
  	  se == "-8. Don't know" | se == "-9. Refused") {
    if (ch == "1. Liberal") {
    	comb = "2. Liberal"
    }
    else if (ch == "2. Conservative"){
    	comb = "6. Conservative"
    }
    else if (ch == "3. Moderate"){
      comb = "4. Moderate"
    }
    else {
    	comb = "-1. Inapplicable"
    }
  }
  else {
    comb = se
  }
  return(comb)
}

check1 = fn_libcpre_comb("4. Moderate; middle of the road","1. Liberal")
check2 = fn_libcpre_comb("4. Moderate; middle of the road","2. Conservative")
check3 = fn_libcpre_comb("2. Conservative","4. Moderate; middle of the road")
check4 = fn_libcpre_comb("4. Moderate; middle of the road", "-9. Refused")

--------------------------------------------------------------------------------------------------------
# Apply functions to a dataframe
convertToKmh <- function(dataset, col_name){
  dataset[col_name] <- dataset$speed * 1.609344
  return(dataset)
}

head(convertToKmh(cars, "speed_in_kmh"))
##   speed dist speed_in_kmh
## 1     4    2     6.437376
## 2     4   10     6.437376
## 3     7    4    11.265408
## 4     7   22    11.265408
## 5     8   16    12.874752
## 6     9   10    14.484096


# Cross-table with colum and row names
col_grad_table = addmargins(table(CEO$college,CEO$grad))
rownames(col_grad_table) = c("No College","Has College Degree","Total")
colnames(col_grad_table) = c("No Grad Degree","Has Grad Degree","Total")
col_grad_table = as.table(col_grad_table)
col_grad_table

# Break into Large and Medium enterprise
comsize = cut(CEO$mktval, breaks = c(-100, 99,999, Inf),
              labels = c('Small Enterprise', 'Medium Enterprise','Large Enterprise'))

summary(comsize)

boxplot(salary ~ comsize, data = CEO, main = "CEO's Salary by the size of the company",
        ylab = "Salary ($'000s)")

# Subset
LE = subset(CEO, CEO$mktval >= 1000)

# Dropping columns
drop <- c("current_is_eligible","prior_is_eligible")
df = members[,!(names(members) %in% drop)]


--------------------------------------------------------------------------------------------------------
# Remove outliers
library(data.table)
outlierReplace = function(dataframe, cols, rows, newValue = NA) {
    if (any(rows)) {
        set(dataframe, rows, cols, newValue)
    }
}

outlierReplace(my_data, "num_students_total_gender.num_students_female", which(my_data$num_students_total_gender.num_students_female > 
    1000), NA)

--------------------------------------------------------------------------------------------------------
# Remove all na observations
Df1 = na.omit(Data)

# Remove na by a specific column
DF[!is.na(DF$y),]

--------------------------------------------------------------------------------------------------------
# Regression
fit <- lm(Dx_Codes ~ TotalChartPages, data = aetna)
summary(fit) # show results
```
```{r}
outlierTest(fit) # Bonferonni p-value for most extreme obs
qqPlot(fit, main="QQ Plot") #qq plot for studentized resid 
leveragePlots(fit) # leverage plots

predict(Model, newdata=new.cars, interval='confidence')

--------------------------------------------------------------------------------------------------------
# Grouping for boxplot
aetna$page_grcut <- cut(aetna$TotalChartPages, 
                       breaks = c(-Inf, 100, 200, 300, 400, 500, Inf), 
                       labels = c("<100", "100-200", "200-300", "300-400", "400-500", "500+"), 
                       right = FALSE)

boxplot(aetna$Dx_Codes~ aetna$page_grcut, main = "NAMM Hospital",
        xlab = "Number of Pages per Chart", ylab = "Number of Dx Codes per Chart")

--------------------------------------------------------------------------------------------------------
# Grouping for summary
bracket <- c(0,12,14,16, Inf)
labels = c("some HS", "HS", "some college", "college")
c1 <- cut(df_knn$meduc, breaks = bracket)
table(c1)
levels(c1) <- labels
table(c1)
df_knn$meduc_level <- c1

by_educ <- group_by(df_knn, meduc_level)
meduc_influence <- summarise(by_educ,
                             avg_bwght = mean(bwght),
                             n = n(),
                             avg_npvis = mean(npvis),
                             avg_omaps = mean(omaps),
                             avg_fmaps = mean(fmaps),
                             avg_feduc = mean(feduc))

meduc_influence

--------------------------------------------------------------------------------------------------------
# filter
outlier_promo = CEO[which(CEO$promo == -2),]

male_bwght = df_knn$bwght[which(df_knn$male == 1)]


--------------------------------------------------------------------------------------------------------
# Cross-table
library(gmodels)
CrossTable(df_na$lbw, df_na$vlbw, format = "SPSS"
          , prop.c = FALSE, prop.r = FALSE, prop.t = FALSE
          , prop.chisq = FALSE)

--------------------------------------------------------------------------------------------------------
# Knn Imputation methodology for missing value
library(DMwR)
df_knn <- n(data[, !knnImputationames(data) %in% "medv"])  # perform knn imputation.
anyNA(df_knn)