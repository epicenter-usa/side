library(tidycensus)
library(tidyverse)
library(colorspace)
library(stringr)
library(sf)
library(geojsonsf)
options(tigris_use_cache = TRUE)


# Function to process all counties from a State ---------------------------

get_block_group_data_state <- function(state) {
  
  # get list of counties for the state
  state_counties <- get_decennial(
    geography = "county",
    state = state,
    variable = "COUNTY"
  )
  
  counties_list <- unique(state_counties$value)
  
  get_blocks <- function(county) {
    print(county)
    
    data_acs_block <- tidycensus::get_acs(
      geography = "block group", 
      state = state, 
      county = county,
      variables = "B01003_001E", 
      geometry = TRUE)
    
    data_acs_block$county_fips <- county
    data_acs_block$state <- state
    
    return(data_acs_block)
  }
  
  blocks_data_list <- map(counties_list, get_blocks)
  
  state_blocks_data <- do.call(rbind, blocks_data_list)
  
  print(paste("End of state", state))
  
  return(state_blocks_data)
}

# process states by "batches" ---------------------------------------------

# skipping Alaska, it seems there's a problem with county 270. Generate later

# batch1_AL_GA <- map(c(state.abb[1],state.abb[3:10]), get_block_data_state)

states_processed <- list()

states_processed[["AL"]] <- get_block_group_data_state("AL")

for (state_no in 3:10) {
  states_processed[[state.abb[state_no]]] <- get_block_group_data_state(state.abb[state_no])
}

saveRDS(states_processed, file = "./data/states_processed.rds")

# plots for testing -------------------------------------------------------

ggplot(states_processed[["AL"]]) + 
  geom_sf(fill = "coral", color = "#FFFFFF22", size = .5) +
  theme_bw()



# process at block level --------------------------------------------------

get_block_data_state <- function(state) {
  
  # get list of counties for the state
  state_counties <- get_decennial(
    geography = "county",
    state = state,
    variable = "COUNTY"
  )
  
  counties_list <- unique(state_counties$value)
  
  get_blocks <- function(county) {
    print(county)
    
    data_acs_block <- tidycensus::get_decennial(
      geography = "block", 
      state = state, 
      county = county,
      variables = "P001001", 
      geometry = TRUE)
    
    data_acs_block$county_fips <- county
    data_acs_block$state <- state
    
    return(data_acs_block)
  }
  
  #blocks_data_list <- map(counties_list, get_blocks)
  #state_blocks_data <- do.call(rbind, blocks_data_list)
  
  counties_processed <- list()
  counties_with_error <- c()
  
  print(counties_list)
  
  for (county in counties_list) {
    tryCatch(
      counties_processed[[county]] <- get_blocks(county),
      error = function(e) {
        counties_with_error <- c(counties_with_error, county)
      }
    ) 
  }
  
  print(paste("End of state", state))
  print(paste("Counties with error", counties_with_error))
  
  return(counties_processed)
}

# process

# for (state_no in 3:10) {
#   states_processed[[state.abb[state_no]]] <- get_block_group_data_state(state.abb[state_no])
# }

states_processed_block <- list()

# ok states_processed_block[["AL"]] <- get_block_data_state("AL")
states_processed_block[["DC"]] <- get_block_data_state("DC")

saveRDS(states_processed_block, file = "./data/states_block_level.rds")


# DC experiment -----------------------------------------------------------

dc <- do.call(rbind, states_processed_block[["DC"]])
sum(dc$value)
dc_block_group <- get_block_group_data_state("DC")

ggplot(dc) + geom_sf()
ggplot(dc_block_group) + geom_sf()

saveRDS(dc, "./data/dc_block_level.rds")
saveRDS(dc_block_group, "./data/dc_block_group_level.rds")

dc_geojson <- geojsonsf::sf_geojson(dc)
dc_blkgrp_geojson <- geojsonsf::sf_geojson(dc_block_group)

write_file(dc_geojson,        "./data/dc_block.geojson")
write_file(dc_blkgrp_geojson, "./data/dc_block_group.geojson")







