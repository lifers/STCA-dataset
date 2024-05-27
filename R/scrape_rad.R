library(tidyverse)
library(rvest)
library(readr)

path_fmt <- "./data/raw/web_data/Refugee Appeals by Country of Alleged Persecution - {year} - Immigration and Refugee Board of Canada.htm"
column_names <- c("country",
                  "filed",
                  "nonmerit_dismiss_jurisdiction",
                  "nonmerit_dismiss_imperfect",
                  "nonmerit_dismiss_other",
                  "merit_dismiss_confirm",
                  "merit_allow_referback",
                  "merit_allow_substitute",
                  "total_finalized",
                  "pending")
spec <- tribble(
  ~.name, ~.value, ~merit, ~outcome,
  "X2", "count", NA, "filed",
  "X3", "count", FALSE, "nonmerit_dismiss_jurisdiction",
  "X4", "count", FALSE, "nonmerit_dismiss_imperfect",
  "X5", "count", FALSE, "nonmerit_dismiss_other",
  "X6", "count", TRUE, "merit_dismiss_confirm",
  "X7", "count", TRUE, "merit_allow_referback",
  "X8", "count", TRUE, "merit_allow_substitute",
  "X9", "count", NA, "total_finalized",
  "X10", "count", NA, "pending",
)

process_yearly <- function(year) {
  file_path <- str_glue(path_fmt)
  page <- read_html(file_path)
  raw_tables <- page %>% html_elements("table")
  
  # standardize month names, make sure all numbers are read as
  # integers instead of characters, and add a Year column.
  scraped_tables <- raw_tables[[1]] %>%
    html_table(na.strings = c("--", "--3", "---", "​--", "--​")) %>%
    slice(-1, -2) %>%
    pivot_longer_spec(spec) %>%
    rename(country = "X1") %>%
    mutate(across(c(country, count), str_squish),
           count = as.integer(parse_number(count))) %>%
    add_column(year = as.integer(year), .before = 1)
  
  return(scraped_tables)
}

final_table <- 2017:2023 %>%
  map(process_yearly) %>%
  bind_rows() %>%
  mutate(
    country = case_match(
      country,
      c("Belarus (Byelorussia)", "Belarus(Byelorussia)") ~ "Belarus",
      c("​Bosnia and Herzegovina") ~ "Bosnia and Herzegovina",
      c("Vietnam") ~ "Viet Nam",
      c("United States") ~ "United States of America",
      c("Turkey") ~ "Türkiye",
      c("Sudan (South)", "Sudan (South)​") ~ "South Sudan",
      c("Saint Vincent") ~ "Saint Vincent and the Grenadines",
      c("Myanmar, Burma", "Myanmar (Burma)") ~ "Myanmar",
      c("​Djibouti") ~ "Djibouti",
      c("Central African Rep") ~ "Central African Republic",
      c("North Macedonia, Republic Of") ~ "North Macedonia",
      c("Korea, Republic of (South Korea)", "Korea R. (South)") ~ "South Korea",
      c("Congo, Republic of the (Brazzaville)") ~ "Congo (Brazzaville)",
      c("Congo, Democratic Republic", "Congo, Democratic Republic of the") ~ "Congo (Kinshasa)",
      c("Hong Kong") ~ "Hong Kong (SAR)",
      c("Swaziland", "Eswatini (Swaziland)") ~ "Eswatini",
      c("Ivory Coast", "Côte d'Ivoire (Ivory Coast)") ~ "Côte d'Ivoire",
      .default = country
    ),
    across(c(country, outcome), as_factor)
  )

final_table %>% saveRDS("./data/intermediate/rad_appeals.rds")
final_table %>% write_csv("./data/intermediate/rad_appeals.csv")