library(shiny)
library(leaflet)
library(sf)
library(dplyr)

# =========================
# UI
# =========================
mod_map_exclusion_ui <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = "700px")
}

# =========================
# SERVER
# =========================
mod_map_exclusion_server <- function(id, data, comunas_sel) {
  moduleServer(id, function(input, output, session) {
    
    pal <- colorFactor(
      palette = c("yellow", "gold", "orange", "darkorange", "red", "darkred"),
      levels  = c("Muy baja", "Baja", "Media", "Alta", "Muy alta", "Extrema"),
      na.color = "#CCCCCC"
    )
    
    # =========================
    # DATOS (LIGEROS)
    # =========================
    datos_mapa <- reactive({
      df <- data()
      req(nrow(df) > 0)
      
      # precalcular color (CLAVE)
      df$fill_col <- pal(df$excl_lab_cat)
      
      # precalcular label (evita recomputar en JS)
      df$label_txt <- paste0(
        "Exclusión laboral: ",
        round(100 * df$porc_excl_lab, 1),
        "% (", df$excl_lab_cat, ")"
      )
      
      df
    })
    
    # =========================
    # MAPA (RENDER EFICIENTE)
    # =========================
    output$map <- renderLeaflet({
      df <- datos_mapa()
      req(nrow(df) > 0)
      
      leaflet(
        df,
        options = leafletOptions(
          preferCanvas = TRUE
        )
      ) %>%
        addProviderTiles(providers$CartoDB.Positron, group = "Base") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") %>%
        
        addPolygons(
          fillColor    = ~fill_col,
          fillOpacity  = 0.85,
          color        = "#333333",
          weight       = 0.2,
          smoothFactor = 0.5,
          label        = ~label_txt,
          group        = "Exclusión laboral"
        ) %>%
        
        addLegend(
          pal     = pal,
          values  = df$excl_lab_cat,
          title   = "Exclusión laboral",
          opacity = 0.9
        ) %>%
        
        addLayersControl(
          baseGroups    = c("Base", "Satélite"),
          overlayGroups = c("Exclusión laboral"),
          options       = layersControlOptions(collapsed = FALSE)
        )
    })
  })
}


