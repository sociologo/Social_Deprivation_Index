# ==========================================
# SocioSpatial Analytics – Chile
# ==========================================

# ── librerías ─────────────────────────────
library(shiny)
library(shinycssloaders)
library(bslib)
library(bsicons)
library(sf)
library(dplyr)
library(leaflet)
library(DT)

options(scipen = 999)

# ── sources ───────────────────────────────
source("global.R")

# ==========================================
# UI
# ==========================================

ui <- page_navbar(
  id = "main_tabs",
  title = "SocioSpatial Analytics – Chile",
  
  theme = bs_theme(
    bootswatch = "flatly",
    primary = "#1b3a4b",
    base_font = font_google("Inter")
  ),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  # ============================
  # MAPA EDUCATIVO
  # ============================
  
  nav_panel(
    "Mapa educativo",
    
    layout_sidebar(
      sidebar = sidebar(
        width = 420,
        mod_filters_ui("filtros"),
        checkboxInput("modo_seg", "Mostrar segregación educativa", FALSE),
        hr(),
        mod_indicadores_ui("indicadores")
      ),
      
      card(
        height = "800px",
        style = "position: relative;",
        
        # ── MAPA ───────────────────────────
        mod_map_escolaridad_ui("map1") |>
          withSpinner(type = 4),
        
        # ── TARJETA LEYENDA ─────────────────
        div(
          style = "
          position: absolute;
          bottom: 20px;
          left: 20px;
          width: 320px;
          z-index: 999;
        ",
          
          card(
            class = "p-3 shadow-sm",
            
            h6("Escolaridad promedio (18+)", class = "mb-2"),
            
            p(
              "Promedio de años de escolaridad de la población de ",
              strong("18 años o más"),
              " residente en cada manzana censal, calculado a partir del ",
              strong("Censo de Población y Vivienda 2024"),
              "."
            ),
            
            p(
              "El indicador se discretiza en tramos de 0,5 años y se utiliza ",
              "como dimensión educativa del ",
              strong("Social Deprivation Index (SDI)."),
              class = "text-muted mb-0"
            )
          )
        )
      )
    )
  ),
  
  
  # ============================
  # METODOLOGÍA
  # ============================
  
  nav_panel(
    "Metodología",
    card(
      class = "p-4",
      uiOutput("texto_metodologia")
    )
  ),
  
  # ============================
  # EXCLUSIÓN LABORAL
  # ============================
  
  nav_panel(
    "Exclusión laboral",
    card(
      height = "800px",
      mod_map_exclusion_ui("map2") |>
        withSpinner(type = 4)
    )
  ),
  
  # ============================
  # COMPARACIÓN COMUNAL
  # ============================
  
  nav_panel(
    "Comparación comunal",
    mod_comparacion_ui("tabla1")
  ),
  
  # ============================
  # SOCIAL DEPRIVATION INDEX
  # ============================
  
  nav_panel(
    "Social Deprivation Index",
    
    layout_sidebar(
      sidebar = sidebar(
        width = 420,
        h4("Índice de Privación Social"),
        p(
          "Construcción, fundamentación y visualización del ",
          strong("Social Deprivation Index (SDI)"),
          " a nivel microterritorial, utilizando exclusivamente datos del CPV24."
        )
      ),
      
      card(
        class = "p-4",
        uiOutput("texto_sdi")
      )
    )
  ),
  
  # ============================
  # DOCKERIZACIÓN
  # ============================
  
  nav_panel(
    "Dockerización",
    
    card(
      class = "p-4",
      
      h3("Dockerización y Despliegue (DevOps-oriented)"),
      
      p(
        "Esta aplicación Shiny ha sido diseñada con un enfoque ",
        strong("DevOps-first"),
        ", permitiendo un despliegue reproducible, portable y escalable ",
        "mediante contenedores Docker."
      ),
      
      hr(),
      
      h4("Objetivos de la contenedorización"),
      tags$ul(
        tags$li("Reproducibilidad completa del entorno de ejecución"),
        tags$li("Aislamiento total de dependencias"),
        tags$li("Despliegue consistente entre desarrollo, staging y producción"),
        tags$li("Facilidad de escalamiento y mantenimiento"),
        tags$li("Soporte nativo para flujos CI/CD")
      ),
      
      h4("Imagen base"),
      p("La aplicación se construye sobre imágenes oficiales del ecosistema Rocker:"),
      tags$pre("rocker/shiny"),
      
      h4("Estructura del contenedor"),
      tags$pre(
        "/app\n",
        " ├── app.R\n",
        " ├── global.R\n",
        " ├── modules/\n",
        " ├── data/\n",
        " ├── www/\n",
        " └── renv.lock"
      )
    )
  )
)

# ==========================================
# SERVER
# ==========================================

server <- function(input, output, session) {
  
  # ── carga de datos global (UNA VEZ) ──────
  init_data()
  
  # ── filtros ─────────────────────────────
  comunas_sel <- mod_filters_server("filtros")
  
  # ========================================
  # CACHE REACTIVO (CLAVE PARA PERFORMANCE)
  # ========================================
  
  data_cache <- reactiveVal(list())
  resumen_cache <- reactiveVal(list())
  
  # ── datos mapa educativo (CACHEADO) ─────
  data_map <- reactive({
    sel <- comunas_sel()
    req(length(sel) > 0)
    
    key <- paste(sort(sel), collapse = "_")
    cache <- data_cache()
    
    if (!is.null(cache[[key]])) {
      return(cache[[key]])
    }
    
    df <- get_comunas_mapa(sel)
    
    cache[[key]] <- df
    data_cache(cache)
    
    df
  })
  
  # ── resumen comunal (CACHEADO) ───────────
  resumen_comunal <- reactive({
    df <- data_map()
    req(nrow(df) > 0)
    
    key <- paste(sort(unique(df$COMUNA)), collapse = "_")
    cache <- resumen_cache()
    
    if (!is.null(cache[[key]])) {
      return(cache[[key]])
    }
    
    res <- df |>
      st_drop_geometry() |>
      group_by(COMUNA) |>
      summarise(
        P10 = quantile(escolaridad_disc, 0.10, na.rm = TRUE),
        P90 = quantile(escolaridad_disc, 0.90, na.rm = TRUE),
        .groups = "drop"
      )
    
    cache[[key]] <- res
    resumen_cache(cache)
    
    res
  })
  
  # ── MAPA EDUCATIVO ───────────────────────
  mod_map_escolaridad_server(
    "map1",
    manzanas_sf     = data_map,
    resumen_comunal = resumen_comunal,
    modo_seg        = reactive(input$modo_seg)
  )
  
  # ── EXCLUSIÓN LABORAL ────────────────────
  data_excl <- reactive({
    sel <- comunas_sel()
    req(length(sel) > 0)
    manzanas_exclusion |> filter(COMUNA %in% sel)
  })
  
  mod_map_exclusion_server("map2", data_excl, comunas_sel)
  
  # ── otros módulos ───────────────────────
  mod_indicadores_server("indicadores", data_map)
  mod_comparacion_server("tabla1", data_map)
  
  # ── textos estáticos ────────────────────
  output$texto_sdi <- renderUI({ HTML("...") })
  output$texto_metodologia <- renderUI({ HTML("...") })
}

shinyApp(ui, server)



