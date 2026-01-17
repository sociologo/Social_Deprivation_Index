library(sf)
library(dplyr)

sf::sf_use_s2(FALSE)

dir.create("data", showWarnings = FALSE)

manzanas_raw <- st_read(
  "Cartografía_censo2024_R13.gdb",
  layer = "Manzanas_CPV24",
  quiet = TRUE
)

manzanas_proc <- manzanas_raw |>
  st_transform(4326)

names(manzanas_proc) <- make.names(names(manzanas_proc), unique = TRUE)

saveRDS(
  manzanas_proc,
  "data/manzanas_r13_simpl.rds"
)

# > source("scripts/prep_manzanas_r13.R")
