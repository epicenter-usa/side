library(tidycensus)
library(tidyverse)
library(colorspace)
library(stringr)
library(sf)

census_api_key("c06729f47ca727f264fec12b37bb65ab2806188f", install = T)

data_dec <- tidycensus::get_decennial(geography = "state", variables = "P001001", geometry = TRUE)
sum(data_dec$value)

data_dec_block <- tidycensus::get_decennial(geography = "block group", variables = "P001001", geometry = TRUE)
sum(data_dec$value)

data_acs <- tidycensus::get_acs(geography = "state", variables = "B01003_001E")
sum(data_acs$estimate)


#data_acs_county <- tidycensus::get_acs(geography = "county", state = state.abb, variables = "B01003_001E", geometry = TRUE)
#saveRDS(data_acs_county, file = "./data/pop_county_shapes_acs.rds")

data_acs_county <- readRDS("./data/pop_county_shapes_acs.rds")

quartis_pop <- summary(data_acs_county$estimate)
#quartis_pop_format <- str_trim(format(unname(quartis_pop), big.mark = "."))

formata_sumario <- function(posicao) {
  unname(format(quartis_pop[posicao], big.mark = "."))
}

plot_county <- data_acs_county %>%
  mutate(pop_faixa = cut(estimate, 
                         breaks = c(0,
                                    unname(quartis_pop["1st Qu."]), 
                                    unname(quartis_pop["Median"]),
                                    unname(quartis_pop["3rd Qu."]), 
                                    Inf),
                         labels = c(
                           paste("Até", formata_sumario("1st Qu.")),
                           paste(formata_sumario("1st Qu."), "a", formata_sumario("Median")),
                           paste(formata_sumario("Median"), "a", formata_sumario("3rd Qu.")),
                           paste("Mais de", formata_sumario("3rd Qu."))
                         )))
  

plot_county$pop_faixa %>% unique()

plot_county %>% count(pop_faixa)

ggplot(plot_county) + 
  geom_sf(color = NA, aes(fill = pop_faixa)) +
  scale_fill_discrete_sequential(palette = "SunsetDark") +
  labs(fill = "Faixa população") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        legend.position = "bottom",
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        legend.key.size = unit(.4, "cm"),
        legend.spacing = unit(.2, "cm"))

#colorspace::hcl_palettes(type = "diverging", plot = TRUE)

hcl_palettes(type = "sequential", plot = TRUE)


# data on block group level -----------------------------------------------

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
  
  state_blocks_data <- bind_rows(blocks_data_list)
  
  print(paste("End of state", state))
  
  return(state_blocks_data)
}

texas_data <- get_block_data_state("TX")
RI_data <- get_block_data_state("RI")

sum(texas_data$estimate)

estados_3_10 <- map(state.abb[3:10], get_block_data_state)

#estados_3_10 <- map(state.abb[3:10], get_block_data_state)
#estados_3_10_data <- bind_rows(estados_3_10)
#saveRDS(estados_3_10_data, file = "./data/estados_3_10_data_sem_geom.rds")

state_counties_ak <- get_decennial(
  geography = "county",
  state = "AK",
  variable = "COUNTY"
)

state.abb


test_counties_tx <- tidycensus::get_decennial(
  geography = "county",
  state = "TX",
  variables = c("P001001", "COUNTY"), 
  geometry = FALSE)

counties_tx <- unique(test_counties_tx$NAME)

text_block_county_tx <- tidycensus::get_decennial(
  geography = "block group",
  state = "TX",
  county = 1,
  variables = c("P001001", "COUNTY"), 
  geometry = FALSE)


get_data <- function(state) {
  census_data <- tidycensus::get_acs(
    geography = "block group", 
    state = state, 
    variables = c("B01003_001E", "BLKGRP", "TRACT", "CONCITY", "COUNTY", "STATE", "REGION"), 
    geometry = FALSE)
  
  return(census_data)
}

tx <- get_data("TX")

all_states <- map(state.abb[1:3], get_data)

data_acs_block <- tidycensus::get_acs(
  geography = "block group", 
  state = state.abb, 
  variables = c("B01003_001E", "BLKGRP", "TRACT", "CONCITY", "COUNTY", "STATE", "REGION"), 
  geometry = FALSE)



data_acs_block_ak <- tidycensus::get_acs(
  geography = "block group", 
  state = "AK", 
  county = 290,
  variables = "B01003_001E", 
  geometry = TRUE)


data_acs_block_ri_2 <- tidycensus::get_acs(
  geography = "block group", 
  state = "RI", 
  county = 3,
  variables = "B01003_001E", 
  geometry = TRUE)


ri1 <- st_set_geometry(data_acs_block_ak, NULL) 
ri2 <- st_set_geometry(data_acs_block_ri, NULL)

ri <- bind_rows(ri1, ri2)
ri_sf <- st_sf(ri, geometry = c(data_acs_block_ak$geometry,data_acs_block_ri$geometry))

ggplot() +
  geom_sf(data = data_acs_block_ri, fill = "coral") +
  geom_sf(data = data_acs_block_ri_2, fill = "dodgerblue")

ggplot(ri_sf) +
  geom_sf()
