library(tidyverse)
library(geojsonio)
library(rjson)

#new_districts
links <- read_csv("redistricting_links.csv")
keep_names <- function(l, kn) {
  l[names(l) %in% kn]
}

states_data <- list(type = "FeatureCollection", features = NULL)

for(i in 1:nrow(links)) {
  temp_geojson <- geojson_read(links$link[i])
  
  for(j in 1:length(temp_geojson$features)) {
    temp_geojson$features[[j]]$properties$district <- paste(links$code[i], str_pad(temp_geojson$features[[j]]$properties$FID, 2, "left", "0"), sep = "-")
    temp_geojson$features[[j]]$properties <- keep_names(temp_geojson$features[[j]]$properties, "district")
  }
  
  states_data$features <- append(states_data$features, temp_geojson$features)
}

#for those not on planscore
CT <- geojson_read("CT_new_districts_clean.geojson")
MS <- geojson_read("MS_new_districts_clean.geojson")
TN <- geojson_read("TN_new_districts_clean.geojson")
LA <- geojson_read("LA_new_districts_clean.geojson")
NY <- geojson_read("NY_new_districts_clean.geojson")
MO <- geojson_read("MO_new_districts_clean.geojson")
MD <- geojson_read("MD_new_districts_clean.geojson")
NH <- geojson_read("NH_new_districts_clean.geojson")

districtize <- function(data, state) {
    for(j in 1:length(data$features)) {
      data$features[[j]]$properties$district <- paste(state, str_pad(data$features[[j]]$properties$district, 2, "left", "0"), sep = "-")
      data$features[[j]]$properties <- keep_names(data$features[[j]]$properties, "district")
    }
  return(data$features)
}

CT2 <- districtize(CT, "CT")
MS2 <- districtize(MS, "MS")
TN2 <- districtize(TN, "TN")
LA2 <- districtize(LA, "LA")
NY2 <- districtize(NY, "NY")
MO2 <- districtize(MO, "MO")
MD2 <- districtize(MD, "MD")
NH2 <- districtize(NH, "NH")

states_data$features <- append(states_data$features, CT2)
states_data$features <- append(states_data$features, MS2)
states_data$features <- append(states_data$features, TN2)
states_data$features <- append(states_data$features, LA2)
states_data$features <- append(states_data$features, NY2)
states_data$features <- append(states_data$features, MO2)
states_data$features <- append(states_data$features, MD2)
states_data$features <- append(states_data$features, NH2)

##old districts
old_states <- c("Alaska", "Delaware", "North Dakota", "South Dakota", "Vermont", "Wyoming")
old_districts <- geojson_read("https://raw.githubusercontent.com/CivilServiceUSA/us-house/master/us-house/geojson/us-house.geojson")

old_geojson <- keep(old_districts$features, ~.x$properties$state_name %in% old_states)


for(j in 1:length(old_geojson)) {
  district_val <- ifelse(is.null(old_geojson[[j]]$properties$district), "01", str_pad(old_geojson[[j]]$properties$district, 2, "left", "0"))
  old_geojson[[j]]$properties$district <- paste(old_geojson[[j]]$properties$state_code, district_val, sep = "-")
  old_geojson[[j]]$properties <- keep_names(old_geojson[[j]]$properties, "district")
}


states_data$features <- append(states_data$features, old_geojson)

json_string <- toJSON(states_data)
write(json_string, "2022-06-08-districts-raw.json")



#####graveyard
# test <- list(type = "FeatureCollection", features = append(states_data[[1]]$features, states_data[[2]]$features))
# 
# data <- geojson_read("https://planscore.s3.amazonaws.com/uploads/20220112T185933.908455299Z/geometry.json")
# 
# sf_test <- geojson_sf("https://planscore.s3.amazonaws.com/uploads/20220112T185933.908455299Z/geometry.json")
# 
# for(i in 1:length(data$features)) {
#   data$features[[i]]$properties$district <- paste0("MD-", data$features[[i]]$properties$FID)
# }
# 
# test <- data$features[[1]]$properties$FID
# 
# str_pad(1, 2, side = "left", pad = "0")
# 
# 
# `%notin%` <- Negate(`%in%`)
# all_states <- c("Arizona", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Illinois", "Oregon", "Massachusettes", "Maryland", "Maine", "Michigan", "Montana", "Minnesota", "Missouri", "New Jersey", "New Mexico", "Nevada", "New York", "Ohio", "Pennsylvania", "Rhode Island", "South Dakota", "Virginia", "Washington", "Vermont", "Alaska", "Alabama", "Arkansas", "Georgia", "Hawaii", "Iowa", "Idaho", "Indiana", "Kansas", "Kentucky", "Louisiana", "Mississippi", "North Carolina", "North Dakota", "Nebraska", "New Hampshire", "Oklahoma", "South Carolina", "Tennessee", "Texas", "Utah", "West Virginia", "Wyoming", "Wisconsin")
# new_states <- all_states[all_states %notin% old_states]
# 
# write(new_states, "new_states.txt")
