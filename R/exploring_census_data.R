library(tidycensus)
library(tidyverse)
census_api_key("c06729f47ca727f264fec12b37bb65ab2806188f", install = T)

data_dec <- tidycensus::get_decennial(geography = "state", variables = "P001001", geometry = TRUE)
sum(data_dec$value)

data_dec_block <- tidycensus::get_decennial(geography = "block group", variables = "P001001", geometry = TRUE)
sum(data_dec$value)

state.abb

data_acs <- tidycensus::get_acs(geography = "state", variables = "B01003_001E")
sum(data_acs$estimate)

data_acs_block <- tidycensus::get_acs(geography = "block group", state = state.abb, variables = "B01003_001E")


