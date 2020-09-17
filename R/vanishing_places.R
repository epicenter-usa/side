library(tidyverse)
library(sf)
library(geojsonsf)

vanish_sf <- geojson_sf("./data/to_mapbox/vanishing_places.json")
usa <- sf::read_sf("./data/cb_2018_us_nation_5m")

ggplot(vanish_sf) +
  geom_sf(data = usa, fill = "ghostwhite") +
  geom_sf(fill = "tomato") + 
  xlim(-180, -60) +
  theme_void()
