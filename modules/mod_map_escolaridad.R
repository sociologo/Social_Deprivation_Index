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
    # DATOS
    # =========================
    datos_mapa <- reactive({
      df <- manzanas_sf()
      req(nrow(df) > 0)
      
      df2 <- df %>%
        st_drop_geometry() %>%
        left_join(
          resumen_comunal() %>% select(COMUNA, P10, P90),
          by = "COMUNA"
        )
      
      st_as_sf(
        df2,
        geometry = st_geometry(df),
        crs = st_crs(df)
      )
    })
    
    # =========================
    # MAPA (PATRÓN QUE FUNCIONA)
    # =========================
    output$map <- renderLeaflet({
      df <- datos_mapa()
      req(nrow(df) > 0)
      
      leaflet(df) %>%
        addProviderTiles(providers$CartoDB.Positron, group = "Base") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") %>%
        
        addPolygons(
          
          
          
          
          
          # fillColor = ~ if (modo_seg()) {
          #   ifelse(
          #     escolaridad_disc <= P10, "#2C7FB8",
          #     ifelse(escolaridad_disc >= P90, "#B10026", "#DDDDDD")
          #   )
          # } else {
          #   pal(escolaridad_disc)
          # }
          
          
          fillColor = ~ if (!modo_seg()) {
            
            pal(escolaridad_disc)
            
          } else {
            
            dplyr::case_when(
              is.na(escolaridad_disc) | is.na(P10) | is.na(P90) ~ "#DDDDDD",
              escolaridad_disc <= P10 ~ "#2C7FB8",
              escolaridad_disc >= P90 ~ "#B10026",
              TRUE ~ "#DDDDDD"
            )
            
          }
          
          
          
          
          
          ,
          fillOpacity = 0.8,
          color = "#333333",
          weight = 0.3,
          smoothFactor = 0.3,
          group = "Escolaridad"
        ) %>%
        
        addLayersControl(
          baseGroups = c("Base", "Satélite"),
          overlayGroups = c("Escolaridad"),
          options = layersControlOptions(collapsed = FALSE)
        )
    })
    
  })
}


