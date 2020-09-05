library(tidycensus)
library(tidyverse)
library(colorspace)
library(stringr)

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

