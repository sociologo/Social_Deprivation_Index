


load_all_data <- function() {
  
  message("Cargando cartografía Censo 2024 (optimizada)...")
  
  manzanas <- readRDS("data/manzanas_r13_simpl.rds")
  
  message("Cartografía cargada: ", nrow(manzanas), " manzanas")
  
  manzanas
}
