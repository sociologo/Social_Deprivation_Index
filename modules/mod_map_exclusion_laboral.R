mod_map_exclusion_ui <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = "700px")
}

mod_map_exclusion_server <- function(id, data, comunas_sel) {
  moduleServer(id, function(input, output, session) {
    
    pal <- colorFactor(
      palette = c("yellow", "gold", "orange", "darkorange", "red", "darkred"),
      levels = c("Muy baja", "Baja", "Media", "Alta", "Muy alta", "Extrema"),
      na.color = "#CCCCCC"
    )
    
    output$map <- renderLeaflet({
      req(data())
      df <- data()
      req(nrow(df) > 0)
      
      leaflet(df) %>%
        addProviderTiles(providers$CartoDB.Positron, group = "Base") %>%
        addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") %>%
        
        addPolygons(
          fillColor = ~pal(excl_lab_cat),
          fillOpacity = 0.85,
          color = "#333333",
          weight = 0.2,
          smoothFactor = 0.3,
          label = ~paste0(
            "Exclusión laboral: ",
            round(100 * porc_excl_lab, 1), "% (", excl_lab_cat, ")"
          ),
          highlightOptions = highlightOptions(
            weight = 1.5,
            color = "#000000",
            fillOpacity = 0.95,
            bringToFront = TRUE
          ),
          group = "Exclusión laboral"
        ) %>%
        
        addLegend(
          pal = pal,
          values = df$excl_lab_cat,
          title = "Exclusión laboral",
          opacity = 0.9
        ) %>%
        
        addLayersControl(
          baseGroups = c("Base", "Satélite"),
          overlayGroups = c("Exclusión laboral"),
          options = layersControlOptions(collapsed = FALSE)
        )
    })
  })
}


