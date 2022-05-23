library(tidyverse)
library(sf)

`%notin%` <- Negate(`%in%`)

old_districts <- st_read("2022-01-26-districts-only-simplified.json")
new_districts <- st_read("2022-03-09-districts-only-simplified-4percent.json")


diff <- old_districts$district[old_districts$district %notin% new_districts$district] 
diff2 <- new_districts$district[new_districts$district %notin% old_districts$district] 

