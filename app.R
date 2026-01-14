# ==========================================
# SocioSpatial Analytics – Chile
# ==========================================

source("modules/mod_map_escolaridad.R")
source("global.R")
library(bslib)
library(bsicons)
library(shiny)
library(shinyjs)
library(shinycssloaders)
library(bslib)

tags$head(
  tags$link(rel = "stylesheet", href = "styles.css"),
  tags$script(src = "app.js")
)


ui <- page_navbar(
  
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
      
      mod_map_escolaridad_ui("map1") |> 
        withSpinner(type = 4)
    )
  ),
  
  # ============================
  # EXCLUSIÓN LABORAL
  # ============================
  
  nav_panel(
    "Exclusión laboral",
    mod_map_exclusion_ui("map2") |> 
      withSpinner(type = 4)
  ),
  
  # ============================
  # COMPARACIÓN COMUNAL
  # ============================
  
  nav_panel(
    "Comparación comunal",
    mod_comparacion_ui("tabla1")
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
  )
)

server <- function(input, output, session) {
  
  comunas_sel <- mod_filters_server("filtros")
  
  # Overlay cuando cambian comunas
  observeEvent(comunas_sel(), {
    shinyjs::show("loading")
  }, ignoreInit = FALSE)
  
  # Datos mapa educativo
  data_map <- eventReactive(comunas_sel(), {
    req(comunas_sel())
    req(length(comunas_sel()) > 0)
    get_comunas_mapa(comunas_sel())
  }, ignoreInit = FALSE)
  
  # Mapa educativo
  mod_map_escolaridad_server("map1", data_map, comunas_sel, reactive(input$modo_seg))
  
  # Mapa exclusión laboral
  data_excl <- eventReactive(comunas_sel(), {
    req(comunas_sel())
    manzanas_exclusion %>%
      filter(COMUNA %in% comunas_sel())
  })
  
  mod_map_exclusion_server("map2", data_excl, comunas_sel)
  
  # Indicadores y tabla
  mod_indicadores_server("indicadores", data_map)
  mod_comparacion_server("tabla1", data_map)
  
  # Texto metodología
  output$texto_metodologia <- renderUI({
    HTML("
    <h3>¿Qué hace esta aplicación?</h3>

    <p>
    Esta plataforma integra datos de la Encuesta CASEN 2022/2024 con cartografía oficial del
    Censo de Población y Vivienda 2024 (CPV24) para construir un sistema de análisis
    socioeducativo y laboral a nivel microterritorial.
    </p>

    <h4>Unidad espacial</h4>
    <p>
    El análisis se realiza a nivel de manzana censal, la unidad territorial más pequeña del
    sistema estadístico chileno, permitiendo detectar patrones de segregación que no son
    visibles a nivel comunal.
    </p>

    <h4>Escolaridad</h4>
    <p>
    Se utiliza la escolaridad promedio de la población adulta (18+) por manzana, discretizada
    en tramos de 0,5 años para facilitar su lectura espacial.
    </p>

    <h4>Segregación educativa</h4>
    <p>
    Para cada comuna se calculan percentiles (P10, P25, P50, P75, P90) y se construyen
    indicadores de segregación (P90/P10) y polarización (P75/P25).
    </p>

    <h4>Exclusión laboral</h4>
    <p>
    A partir del CPV24 se calcula el porcentaje de población fuera del mercado laboral
    (desocupados + inactivos) sobre la fuerza laboral total en cada manzana.
    </p>

    <h4>Visualización</h4>
    <p>
    Los mapas permiten alternar entre niveles absolutos y extremos territoriales, revelando
    guetos sociales y enclaves de élite.
    </p>
    ")
  })
  
}

shinyApp(ui, server)



