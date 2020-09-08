library(tidycensus)
library(tidyverse)
library(colorspace)
library(stringr)
library(sf)
library(geojsonsf)


options(tigris_use_cache = TRUE)

# county map --------------------------------------------------------------


#data_acs_county <- tidycensus::get_acs(geography = "county", state = state.abb, variables = "B01003_001E", geometry = TRUE)
#saveRDS(data_acs_county, file = "./data/pop_county_shapes_acs.rds")

data_acs_county <- readRDS("./data/pop_county_shapes_acs.rds")

counties <- geojsonsf::sf_geojson(data_acs_county)
write_file(counties, "./data/to_mapbox/counties.geojson")

# usa map -----------------------------------------------------------------

usa <- tidycensus::get_acs(geography = "nation", variables = "B01003_001E", geometry = TRUE)

usa <- sf::read_sf("./data/cb_2018_us_nation_5m")
ggplot(usa) + geom_sf()


# expanded coasts



