library(tidycensus)
library(tidyverse)
library(colorspace)
library(stringr)
library(sf)

options(tigris_use_cache = TRUE)

list_counties <- read_rds("./data/counties.rds")
list_states   <- read_rds("./data/states.rds")

counties_ny <- list_counties %>%
  filter(str_sub(GEOID, 1, 2) == "36")

state_counties_NY <- get_decennial(
  geography = "county",
  state = "36",
  variable = "COUNTY"
)

blockgroups_manhattan <- tidycensus::get_acs(geography = "block group", 
                                             state = "NY",
                                             county = 61,
                                             variables = "B01003_001E", 
                                             geometry = TRUE)

blockgroups_saltlake <- tidycensus::get_acs(geography = "block group", 
                                             state = 49,
                                             county = 35,
                                             variables = "B01003_001E", 
                                             geometry = TRUE)

area_manhattan <- st_area(blockgroups_manhattan)
blockgroups_manhattan$area <- as.numeric(area_manhattan)
plot_manhattan <- blockgroups_manhattan %>%
  mutate(density = estimate / area,
         id = GEOID)

pop_manhattan <- sum(blockgroups_manhattan$estimate)

area_salt <- st_area(blockgroups_saltlake)
blockgroups_saltlake$area <- as.numeric(area_salt)
plot_salt<- blockgroups_saltlake %>%
  mutate(density = estimate / area)

pop_salt <- sum(blockgroups_saltlake$estimate)

ggplot(plot_manhattan) + 
  geom_sf(aes(fill = density), color = NA) +
  scale_fill_continuous_sequential() + 
  theme_void()

ggplot(plot_salt) + 
  geom_sf(aes(fill = density), color = NA) +
  scale_fill_continuous_sequential() + 
  theme_void()

blockgroups_nyc_slc <- do.call("bind_rows", list(blockgroups_manhattan, blockgroups_saltlake)) %>%
  mutate(state = str_sub(GEOID, 1, 2))

ggplot(blockgroups_saltlake) + 
  geom_sf(aes(fill = estimate), color = "ghostwhite") +
  scale_fill_continuous_sequential() + 
  theme_void()


# saves manhattan data ----------------------------------------------------

mht <- geojsonsf::sf_geojson(plot_manhattan)
write_file(mht, "./data/to_mapbox/manhattan_blkgrp.geojson")
