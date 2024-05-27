library(tidyverse)
library(rvest)
library(readr)

path_fmt <- "./data/raw/web_data/Asylum claims by year – {year} - Canada.ca.htm"
table_names <- c("rcmp_interceptions",
                 "cbsa_air_entry",
                 "cbsa_land_entry",
                 "cbsa_marine_entry",
                 "cbsa_all_entry",
                 "cbsa_inland_entry",
                 "cbsa_all_entry",
                 "ircc_processed",
                 "cbsa_plus_ircc")
subdiv_names <- c("province",
                  "prov_territory",
                  "prov_territory",
                  "prov_territory",
                  "prov_territory",
                  "prov_territory",
                  "cbsa_office",
                  "prov_territory",
                  "prov_territory")
col_names <- c("january",
               "february",
               "march",
               "april",
               "may",
               "june",
               "july",
               "august",
               "september",
               "october",
               "november",
               "december",
               "total")

process_yearly <- function(year) {
  file_path <- str_glue(path_fmt)
  page <- read_html(file_path)
  raw_tables <- page %>% html_elements("table")
  
  # standardize month names, make sure all numbers are read as
  # integers instead of characters, and add a year column.
  scraped_tables <- raw_tables %>%
    map(html_table, na.strings = "--") %>%
    map(rename_with, .fn = ~ col_names, .cols = 2:14) %>%
    map(mutate, across(january:total & where(is.character), parse_number)) %>%
    map(mutate, across(where(is.numeric), as.integer)) %>%
    map(add_column, year = as.integer(year), .before = 1)
  
  for (i in 1:9) {
    colnames(scraped_tables[[i]])[2] <- subdiv_names[i]
  }
  
  return(scraped_tables)
}

all_tables <- 2017:2023 %>%
  map(process_yearly)

# select only RCMP tables from all_tables and bind them together
rcmp_table <- all_tables %>%
  map(pluck, 1) %>%
  map(select, -total) %>%
  map(slice, -n()) %>%
  bind_rows()

rcmp_table %>% saveRDS("./data/intermediate/rcmp_interceptions.rds")
rcmp_table %>% write_csv("./data/intermediate/rcmp_interceptions.csv")

# do the same for CBSA and IRCC tables
normal_read <- function(index) {
  table <- all_tables %>% map(pluck, index) %>% bind_rows()
  table %>% saveRDS(str_glue("./data/intermediate/{table_names[index]}.rds"))
  table %>% write_csv(str_glue("./data/intermediate/{table_names[index]}.csv"))
}

2:9 %>% map(normal_read)