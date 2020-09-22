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

# faltou DC, que não está em state.abb! :/
#data_acs_county_dc_pr <- tidycensus::get_acs(geography = "county", state = c("DC", "PR"), variables = "B01003_001E", geometry = TRUE)
#saveRDS(data_acs_county_dc_pr, file = "./data/pop_county_shapes_acs_dc_pr.rds")

data_acs_county_dc_pr <- readRDS("./data/pop_county_shapes_acs_dc_pr.rds")

lista_county <- list(data_acs_county, data_acs_county_dc_pr)

data_acs_county_full <- do.call(rbind, lista_county)

ggplot(data_acs_county_dc_pr) + geom_sf()

# checks population of counties dataset -----------------------------------

counties_no_sf <- data_acs_county_full
st_geometry(counties_no_sf) <- NULL

data_acs <- readRDS("./data/states_pops_acs.rds")

pop_state <- counties_no_sf %>% 
  mutate(GEOID = str_sub(GEOID,1,2)) %>%
  group_by(GEOID) %>%
  summarise(pop = sum(estimate)) %>%
  ungroup() %>%
  right_join(data_acs) %>%
  mutate(dif_pop = estimate - pop)



# convert counties map to geojson -----------------------------------------

counties <- geojsonsf::sf_geojson(data_acs_county_full)
write_file(counties, "./data/to_mapbox/counties.geojson")



# usa map -----------------------------------------------------------------

#usa <- tidycensus::get_acs(geography = "nation", variables = "B01003_001E", geometry = TRUE)

usa <- sf::read_sf("./data/cb_2018_us_nation_5m")
ggplot(usa) + geom_sf()


# expanded coasts

coasts <- list()

coasts[["east_coast"]] <- geojson_sf("./data/coast_polygons/east_coast.json")
coasts[["west_coast"]] <- geojson_sf("./data/coast_polygons/west_coast.json")
coasts[["alaska_coast"]] <- geojson_sf("./data/coast_polygons/alaska_adjusted.json")
coasts[["alaska_orient"]] <- geojson_sf("./data/coast_polygons/alaska_orient.json")
coasts[["hawaii_coast"]] <- geojson_sf("./data/coast_polygons/hawaii.json")
coasts[["puerto_rico_coast"]] <- geojson_sf("./data/coast_polygons/puerto_rico.json")

coasts_sf <- coasts[[1]]

for (i in 1:length(coasts)) {
  print(i)
  st_crs(coasts[[i]]) <- st_crs(usa)
  if (i > 1) coasts_sf <- sf::st_union(coasts_sf, coasts[[i]])
}

ggplot(coasts_sf) + geom_sf()

usa_expanded <- sf::st_union(
  usa, 
  coasts_sf)

ggplot(usa_expanded) + geom_sf() + xlim(-200,-60)
ggplot(usa) + geom_sf() + xlim(-200,-60)



# world -------------------------------------------------------------------

world <- geojson_sf("./data/world.geojson")

st_crs(world) <- st_crs(usa)

world_crs <- st_transform(world, st_crs(world))

usa_mask <- sf::st_difference(world_crs, usa_expanded)

saveRDS(usa_mask, "./data/usa_mask.rds")
usa_mask <- read_rds("./data/usa_mask.rds")

ggplot(usa_mask) + geom_sf(fill = "lightcoral")

usa_mask_geojson <- geojsonsf::sf_geojson(usa_mask)
write_file(usa_mask_geojson, "./data/to_mapbox/usa_mask.geojson")



# counties from tiger db --------------------------------------------------

counties <- sf::read_sf("./data/tl_2019_us_county")
saveRDS(counties, "./data/all_counties.rds")

write_file(
  geojsonsf::sf_geojson(counties), 
  "./data/to_mapbox/all_counties.geojson")

ggplot(counties) + geom_sf()
