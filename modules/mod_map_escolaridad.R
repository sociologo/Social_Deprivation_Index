library(shiny)
library(leaflet)
library(sf)
library(dplyr)

# =========================
# UI
# =========================
mod_map_escolaridad_ui <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = "700px")
}

# =========================
# SERVER
# =========================
mod_map_escolaridad_server <- function(
    id,
    manzanas_sf,
    resumen_comunal,
    modo_seg
) {
  moduleServer(id, function(input, output, session) {
    
    pal <- pal_escolaridad()
    
    # =========================
    # DATOS (LIGEROS)
    # =========================
    datos_mapa <- reactive({
      df <- manzanas_sf()
      req(nrow(df) > 0)
      
      # join SOLO atributos, sin tocar geometría
      df <- df |>
        left_join(
          resumen_comunal() |> select(COMUNA, P10, P90),
          by = "COMUNA"
        )
      
      # precalcular colores (CLAVE)
      df$fill_col <- if (!modo_seg()) {
        
        pal(df$escolaridad_disc)
        
      } else {
        
        dplyr::case_when(
          is.na(df$escolaridad_disc) |
            is.na(df$P10) |
            is.na(df$P90) ~ "#DDDDDD",
          
          df$escolaridad_disc <= df$P10 ~ "#2C7FB8",
          df$escolaridad_disc >= df$P90 ~ "#B10026",
          TRUE ~ "#DDDDDD"
        )
      }
      
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
          fillOpacity  = 0.8,
          color        = "#333333",
          weight       = 0.2,
          smoothFactor = 0.5,
          group        = "Escolaridad",
          
          # ── TOOLTIP MINIMAL ───────────────────
          label = ~ifelse(
            is.na(escolaridad_disc),
            "Sin dato",
            paste0(escolaridad_disc, " años")
          ),
          
          labelOptions = labelOptions(
            direction = "auto",
            textsize = "12px",
            opacity = 0.9
          )
          
          
        ) %>%
        
        addLayersControl(
          baseGroups    = c("Base", "Satélite"),
          overlayGroups = c("Escolaridad"),
          options       = layersControlOptions(collapsed = FALSE)
        )
    })
  })
}


