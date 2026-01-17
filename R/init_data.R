
# script de inicialización controlada

# La función init_data() ejecuta la fase 
#    de inicialización pesada de la aplicación.
# Se ejecuta una sola vez al arranque y 
#    construye objetos globales cacheados, no reactivos.

# # init_data.R
# ------------------------------------------------
# Fase de inicialización pesada del sistema.
# Crea objetos globales cacheados:
# - manzanas_exclusion
# - manzanas_pre
# - resumen_comunal_cache
# ------------------------------------------------


# ==========================================
# Inicialización de datos y caches globales
# ==========================================

init_data <- function() {
  
  message("Inicializando datos socioespaciales...")
  load_all_data()
  
  names(manzanas)[names(manzanas) == "" | is.na(names(manzanas))] <- "X_vacio"
  
  manzanas <<- manzanas %>%
    mutate(COMUNA = trimws(toupper(COMUNA)))
  
  # ── exclusión laboral ──────────────────
  message("Calculando exclusión laboral...")
  
  manzanas_exclusion <<- manzanas %>%
    mutate(
      total_laboral = n_ocupado + n_desocupado + n_fuera_fuerza_trabajo,
      porc_excl_lab = {
        out <- NA_real_
        idx <- total_laboral > 0
        out[idx] <- 
          (n_desocupado[idx] + n_fuera_fuerza_trabajo[idx]) / total_laboral[idx]
        out
      },
      excl_lab_cat = cut(
        porc_excl_lab,
        breaks = c(0, 0.11, 0.345, 0.425, 0.491, 0.6, 1),
        labels = c("Muy baja", "Baja", "Media", "Alta", "Muy alta", "Extrema"),
        include.lowest = TRUE
      )
    )
  
  # ── escolaridad ────────────────────────
  message("Calculando escolaridad por manzana...")
  
  manzanas_pre <<- manzanas %>%
    mutate(
      esc_raw  = floor(prom_escolaridad18 * 2) / 2,
      esc_clip = pmin(pmax(8.5, esc_raw), 17),
      escolaridad_disc = esc_clip,
      escolaridad_col  = ifelse(is.na(prom_escolaridad18), 8.4, esc_clip)
    ) %>%
    select(-esc_raw, -esc_clip)
  
  # ── resumen comunal ────────────────────
  message("Construyendo cache comunal...")
  
  resumen_comunal_cache <<- manzanas_pre %>%
    select(COMUNA, escolaridad_disc) %>%
    st_drop_geometry() %>%
    group_by(COMUNA) %>%
    summarise(
      n_manzanas = n(),
      escolaridad_mean = mean(escolaridad_disc, na.rm = TRUE),
      escolaridad_sd   = sd(escolaridad_disc, na.rm = TRUE),
      escolaridad_min  = min(escolaridad_disc, na.rm = TRUE),
      escolaridad_max  = max(escolaridad_disc, na.rm = TRUE),
      
      P10 = quantile(escolaridad_disc[escolaridad_disc > 8.5], 0.10, na.rm = TRUE),
      P25 = quantile(escolaridad_disc[escolaridad_disc > 8.5], 0.25, na.rm = TRUE),
      P50 = quantile(escolaridad_disc[escolaridad_disc > 8.5], 0.50, na.rm = TRUE),
      P75 = quantile(escolaridad_disc[escolaridad_disc > 8.5], 0.75, na.rm = TRUE),
      P90 = quantile(escolaridad_disc[escolaridad_disc > 8.5], 0.90, na.rm = TRUE),
      
      Segregacion  = P90 / P10,
      Polarizacion = P75 / P25,
      
      .groups = "drop"
    )
  
  message("Inicialización completada.")
}
