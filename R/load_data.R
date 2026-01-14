# load_all_data <- function() {
#   
#   message("Cargando cartografía Censo 2024...")
#   
#   manzanas <<- st_read(
#     "Cartografía_censo2024_R13.gdb",
#     layer = "Manzanas_CPV24",
#     quiet = TRUE
#   ) |> 
#     st_transform(4326)   # ← ESTO ES CRÍTICO
#   
#   message("Cartografía cargada: ", nrow(manzanas), " manzanas")
# }


load_all_data <- function() {
  
  message("Cargando cartografía Censo 2024...")
  
  manzanas <<- st_read(
    "Cartografía_censo2024_R13.gdb",
    layer = "Manzanas_CPV24",
    quiet = TRUE
  ) |>
    st_transform(4326)
  
  # 🔥 LIMPIAR columnas sin nombre
  nms <- names(manzanas)
  bad <- which(nms == "" | is.na(nms))
  if (length(bad) > 0) {
    nms[bad] <- paste0("X", bad)
    names(manzanas) <- nms
  }
  
  message("Cartografía cargada: ", nrow(manzanas), " manzanas")
}