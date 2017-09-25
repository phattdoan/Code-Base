-----------------------------------------------------------------------------------------------
## read CSV
####################################
raws_score = read.csv(file = "Data/RAF2016_v2.csv", header=TRUE, sep=",")
head(raws_score)


-----------------------------------------------------------------------------------------------
## joining table
####################################
members.15.over65.transformed4 = left_join(members.15.over65.transformed3, 
                                          members.15.over65, "EMPI")


-----------------------------------------------------------------------------------------------
## Function: bin and aggregate 
####################################
fn_bin_vector = function(vec, bin){
  vec = sort(vec, decreasing = TRUE)
  #str(vec)
  bin.sum = rep(0, bin)
  idx = 1
  for (b in 1:bin){
    cumsum = 0
    #flag = FALSE
    for (i in idx:length(vec)){
      cumsum = cumsum + vec[i]
      #print(idx)
      #print(b)
      if (i/length(vec) > (b/bin)){
        break
      }
    }
    idx = i+1
    bin.sum[b] = cumsum
  }
  return(bin.sum)
}

-----------------------------------------------------------------------------------------------
## Fucntion to calculate distance between 2 geocodes
####################################
```{r}
get_geo_distance = function(lon1, lat1, lon2, lat2, units = "km") {
  distance_Haversine = distm(c(lon1, lat1), c(lon2, lat2), fun = distHaversine)
  
  if (units == "km") {
    distance = distance_Haversine  / 1000.0
  }
  else if (units == "miles") {
    distance = distance_Haversine / 1609.344
  }
  #else if (units == "meters"){
  #  distance = distance_Haversine  / 1000000.0
  #}
  else {
    distance = distance_Haversine
    # This will return in meter as same way as distHaversine function. 
  }
  distance
}

#distance between one grid
grid_length = get_geo_distance(-113, 42, -112.5, 41.5, "km")

print("Grid length in km: ")
print(grid_length[1])

#QA Script to test the function
#test = get_geo_distance(members$Longitude[1], members$Latitude[1], 
#                        centers$lon[1], centers$lat[1], 'meters')

#test[1]

```

## Calculate distance of each member to each clinic
```{r}
for (i in 1:length(centers$name.cleaned)){
  name = centers$name.cleaned[i]
  members.15.over65 <- cbind(members.15.over65, name)
  members.15.over65$name = 0
  print(centers$Name[i])
  for (j in 1:length(members.15.over65$Latitude)){
     temp =  get_geo_distance(centers$lon[i], centers$lat[i], 
                                           members.15.over65$Longitude[j],
                                           members.15.over65$Latitude[j],
                                           "meters")
     members.15.over65$name[j] = temp[1]
  }
  colnames(members.15.over65)[(names(members.15.over65)) == "name"] = paste(centers$name.cleaned[i],
                                                        "distance",sep=".")
}

colnames(members.15.over65)

# QA Script
#centers$lon[1]
#centers$lat[1] 
#members.15$Latitude[1]
#members.15$Longitude[1]
#print(get_geo_distance(centers$lon[1], centers$lat[1], 
#                                           members.15$Longitude[1],
#                                           members.15$Latitude[1],
#                                           "meters"))
```
