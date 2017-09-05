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
