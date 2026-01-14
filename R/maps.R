get_comunas_mapa <- function(comunas_seleccionadas) {
  manzanas_pre %>%
    dplyr::filter(COMUNA %in% comunas_seleccionadas)
}

get_resumen_comunal <- function(df) {
  comunas <- unique(df$COMUNA)
  resumen_comunal_cache %>%
    dplyr::filter(COMUNA %in% comunas)
}

get_comunas_exclusion <- function(comunas) {
  
  manzanas_pre %>%
    filter(COMUNA %in% comunas) %>%
    mutate(
      porc_excl_lab = 
        (n_desocupado + n_fuera_fuerza_trabajo) /
        (n_ocupado + n_desocupado + n_fuera_fuerza_trabajo),
      
      excl_lab_cat = cut(
        porc_excl_lab,
        breaks = c(0, 0.11, 0.345, 0.425, 0.491, 0.6, 1),
        labels = c("Muy baja", "Baja", "Media", "Alta", "Muy alta", "Extrema"),
        include.lowest = TRUE
      )
    )
}
