library(shiny)
library(leaflet)
library(sf)
library(dplyr)

# -------------------------------
# UI
# -------------------------------
mod_map_escolaridad_ui <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = 700)
}

# -------------------------------
# SERVER
# -------------------------------
mod_map_escolaridad_server <- function(id, manzanas_sf, comunas_input, modo_seg) {
  
  moduleServer(id, function(input, output, session) {
    
    pal <- pal_escolaridad()
    
    # ===========================
    # 0️⃣ Datos con percentiles
    # ===========================
    
    datos_mapa <- reactive({
      df <- manzanas_pre %>%
        dplyr::filter(COMUNA %in% comunas_input())
      
      req(nrow(df) > 0)
      
      percentiles <- resumen_comunal_cache %>%
        dplyr::select(COMUNA, P10, P90)
      
      df2 <- dplyr::left_join(
        sf::st_drop_geometry(df),
        percentiles,
        by = "COMUNA"
      )
      
      sf::st_as_sf(
        dplyr::bind_cols(df2, sf::st_geometry(df))
      )
    })
    
    # ===========================
    # 1️⃣ Crear mapa base
    # ===========================
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addTiles(group = "base_invisible", options = tileOptions(opacity = 0)) %>%
        addProviderTiles(providers$CartoDB.Positron, group = "Geografía") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "Calles") %>%
        addLayersControl(
          overlayGroups = c("Escolaridad", "Geografía", "Calles"),
          options = layersControlOptions(collapsed = FALSE)
        )
    })
    
    # ===========================
    # 2️⃣ Dibujar manzanas
    # ===========================
    
    observe({
      df <- datos_mapa()
      req(nrow(df) > 0)
      
      leafletProxy(session$ns("map"), deferUntilFlush = TRUE) %>%
        clearGroup("Escolaridad") %>%
        clearControls() %>%
        
        addPolygons(
          data = df,
          group = "Escolaridad",
          fillColor = ~{
            if (modo_seg()) {
              
              ifelse(
                escolaridad_disc <= 8.5 | is.na(escolaridad_disc),
                "#EEEEEE",
                
                ifelse(
                  escolaridad_disc <= P10 & P10 > 8.5, "#2C7FB8",
                  ifelse(escolaridad_disc >= P90, "#B10026", "#DDDDDD")
                )
              )
              
            } else {
              ifelse(
                escolaridad_disc == 8.5 | is.na(escolaridad_disc),
                "#C8F2C8",
                pal(escolaridad_disc)
              )
            }
          },
          fillOpacity = 0.8,
          color = "#444444",
          weight = 0.3,
          smoothFactor = 0.5,
          highlightOptions = highlightOptions(
            weight = 1.5,
            color = "#000000",
            fillOpacity = 0.9,
            bringToFront = TRUE
          ),
          label = ~paste0(
            "Comuna: ", COMUNA,
            "<br>Escolaridad: ", escolaridad_disc
          )
        ) %>%
        addLegend(
          position = "bottomright",
          colors = if (modo_seg()) c("#2C7FB8", "#DDDDDD", "#B10026") else c("#C8F2C8", pal(9:17)),
          labels = if (modo_seg()) c("Gueto educativo", "Clase media", "Elite educativa") else c("NA / 8.5", 9:17),
          title = if (modo_seg()) "Extremos educativos" else "Escolaridad promedio (18+)",
          opacity = 0.9
        )
    })
    
    # ===========================
    # 3️⃣ Zoom automático
    # ===========================
    
    observeEvent(comunas_input(), {
      comunas <- comunas_input()
      df <- manzanas_sf()
      
      req(length(comunas) > 0)
      req(nrow(df) > 0)
      
      df_ref <- df %>% filter(COMUNA %in% comunas)
      req(nrow(df_ref) > 0)
      
      bbox <- st_bbox(df_ref)
      
      leafletProxy(session$ns("map")) %>%
        fitBounds(
          as.numeric(bbox["xmin"]),
          as.numeric(bbox["ymin"]),
          as.numeric(bbox["xmax"]),
          as.numeric(bbox["ymax"])
        )
      
      session$sendCustomMessage("map_ready", TRUE)
      
    }, ignoreInit = FALSE)
    
  })
}
