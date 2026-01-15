# ==========================================
# Inicialización de datos y caches globales
# ==========================================

init_data <- function() {
  
  message("Inicializando datos socioespaciales...")
  
  # ── carga base ───────────────────────────
  load_all_data()
  
  # ── limpieza de columnas ────────────────
  names(manzanas)[names(manzanas) == "" | is.na(names(manzanas))] <- "X_vacio"
  
  # ============================================================
  # 1️⃣ Exclusión laboral por manzana (CPV24)
  # ============================================================
  
  message("Calculando exclusión laboral...")
  
  manzanas_exclusion <<- manzanas %>%
    mutate(
      COMUNA = trimws(toupper(COMUNA)),
      
      total_laboral = n_ocupado + n_desocupado + n_fuera_fuerza_trabajo,
      
      porc_excl_lab = ifelse(
        total_laboral > 0,
        (n_desocupado + n_fuera_fuerza_trabajo) / total_laboral,
        NA_real_
      ),
      
      excl_lab_cat = cut(
        porc_excl_lab,
        breaks = c(0, 0.11, 0.345, 0.425, 0.491, 0.6, 1),
        labels = c("Muy baja", "Baja", "Media", "Alta", "Muy alta", "Extrema"),
        include.lowest = TRUE
      )
    )
  
  # ============================================================
  # 2️⃣ Escolaridad por manzana
  # ============================================================
  
  message("Calculando escolaridad por manzana...")
  
  manzanas_pre <<- manzanas %>%
    mutate(
      COMUNA = trimws(toupper(COMUNA)),
      
      escolaridad_disc = pmin(
        pmax(8.5, floor(prom_escolaridad18 * 2) / 2),
        17
      ),
      
      escolaridad_col = ifelse(
        is.na(prom_escolaridad18),
        8.4,
        pmin(
          pmax(8.5, floor(prom_escolaridad18 * 2) / 2),
          17
        )
      )
    )
  
  # ============================================================
  # 3️⃣ Cache comunal de segregación
  # ============================================================
  
  message("Construyendo cache comunal...")
  
  resumen_comunal_cache <<- manzanas_pre %>%
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
