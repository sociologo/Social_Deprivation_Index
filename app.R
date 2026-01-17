# ==========================================
# SocioSpatial Analytics – Chile
# ==========================================


# Este archivo NO debe contener lógica cartográfica fina.



# ── librerías ─────────────────────────────
library(shiny)
library(shinyjs)
library(shinycssloaders)
library(bslib)
library(bsicons)
library(sf)
library(dplyr)
library(leaflet)
library(survey)
library(haven)
library(shinydashboard)
library(DT)

options(scipen = 999)


# ── sources ───────────────────────────────
source("global.R")

# ── carga de datos (puede quedar aquí por ahora) ──
data_loaded <- FALSE

ui <- page_navbar(
  id = "main_tabs",
  title = "SocioSpatial Analytics – Chile",
  
  theme = bs_theme(
    bootswatch = "flatly",
    primary = "#1b3a4b",
    base_font = font_google("Inter")
  ),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
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
        mod_map_escolaridad_ui("map1") |> 
          withSpinner(type = 4)
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
  
  # ============================
  # DOCKERIZACIÓN / DEVOPS
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
      tags$ul(
        tags$li("R y Shiny Server preinstalados"),
        tags$li("Ejecución nativa en Linux"),
        tags$li("Imágenes mantenidas y ampliamente adoptadas en producción")
      ),
      
      h4("Gestión de dependencias"),
      p(
        "Las dependencias del entorno R se gestionan mediante ",
        code("renv"),
        ", permitiendo builds determinísticos y entornos inmutables."
      ),
      tags$ul(
        tags$li("Uso de ", code("renv.lock"), " como contrato de dependencias"),
        tags$li("Restauración automática del entorno durante el build"),
        tags$li("Eliminación de errores tipo 'works on my machine'")
      ),
      
      h4("Estructura del contenedor"),
      tags$pre(
        "/app\n",
        " ├── app.R\n",
        " ├── global.R\n",
        " ├── modules/\n",
        " ├── data/\n",
        " ├── geo/\n",
        " ├── www/\n",
        " ├── renv/\n",
        " └── renv.lock"
      ),
      p(
        "No se incluyen fuentes pesadas o no portables (por ejemplo, ",
        code(".gdb"),
        "); solo datos optimizados como ",
        code(".rds"),
        " y ",
        code(".gpkg"),
        "."
      ),
      
      h4("Runtime y networking"),
      tags$ul(
        tags$li("Ejecución mediante Shiny Server"),
        tags$li("Exposición HTTP estándar con puertos configurables"),
        tags$li("Compatibilidad con proxies reversos (NGINX, Traefik)"),
        tags$li("Modelo de ejecución stateless")
      ),
      
      h4("Estrategias de despliegue"),
      tags$ul(
        tags$li("Servidores Linux (on-premise o cloud)"),
        tags$li("AWS, GCP, Azure"),
        tags$li("Infraestructura institucional"),
        tags$li("Entornos de testing y staging"),
        tags$li("Preparado para orquestadores de contenedores")
      ),
      
      h4("CI/CD readiness"),
      tags$ul(
        tags$li("Repositorio limpio y sin binarios"),
        tags$li("Builds determinísticos"),
        tags$li("Versionado controlado de imágenes"),
        tags$li("Integración directa con GitHub Actions")
      ),
      
      hr(),
      
      p(
        em(
          "La contenedorización no es un agregado posterior, sino una decisión ",
          "arquitectónica que guía la estructura del código, los datos y el ",
          "ciclo de vida del despliegue."
        )
      )
    )
  )
  
)
  


server <- function(input, output, session) {
  

  
  # ── carga de datos ───────────────────────
  # carga de datos
  init_data()
  
  # ── filtros ─────────────────────────────
  comunas_sel <- mod_filters_server("filtros")
  
  # ── datos mapa educativo ─────────────────
  data_map <- eventReactive(comunas_sel(), {
    req(length(comunas_sel()) > 0)
    get_comunas_mapa(comunas_sel())
  })
  
  
  observe({
    cat(
      "\n[CHECK TAB]",
      "exists =", !is.null(input$main_tabs),
      "| value = <", isolate(input$main_tabs), ">\n"
    )

    observe({
      w <- session$clientData$output_map1_map_width
      h <- session$clientData$output_map1_map_height

      cat(
        "\n[CHECK MAP DOM]",
        "width =", ifelse(is.null(w), "NULL", w),
        "| height =", ifelse(is.null(h), "NULL", h),
        "\n"
      )
    })

    observeEvent(data_map(), {
      df <- data_map()

      cat(
        "\n[CHECK DATA]",
        "nrow =", nrow(df),
        "| CRS =", sf::st_crs(df)$epsg,
        "\n"
      )
    })

    observeEvent(data_map(), {
      bbox <- sf::st_bbox(data_map())

      cat(
        "\n[CHECK BBOX]",
        "xmin =", bbox["xmin"],
        "| ymin =", bbox["ymin"],
        "| xmax =", bbox["xmax"],
        "| ymax =", bbox["ymax"],
        "\n"
      )
    })
    

    
  #### =========================
  #### TESTS ZOOM / TIMING LEAFLET
  #### =========================
  
  # 1️⃣ Cambio de tab (confirma visibilidad real del panel)
  observeEvent(input$main_tabs, {
    cat(
      "\n[TEST TAB CHANGE]",
      "tab =", input$main_tabs,
      "| time =", Sys.time(),
      "\n"
    )
  }, ignoreInit = TRUE)
  
  # 2️⃣ DOM del mapa: tamaño real (CLAVE)
  observeEvent(
    session$clientData$output_map1_map_width,
    {
      cat(
        "\n[DOM READY]",
        "width =", session$clientData$output_map1_map_width,
        "| height =", session$clientData$output_map1_map_height,
        "| time =", Sys.time(),
        "\n"
      )
    },
    ignoreInit = TRUE
  )
  
  # 3️⃣ Datos espaciales listos
  observeEvent(data_map(), {
    cat(
      "\n[DATA READY]",
      "nrow =", nrow(data_map()),
      "| CRS =", sf::st_crs(data_map())$epsg,
      "| time =", Sys.time(),
      "\n"
    )
  }, ignoreInit = TRUE)
  
  # 4️⃣ Bounding box calculada correctamente
  observeEvent(data_map(), {
    bb <- sf::st_bbox(data_map())
    cat(
      "\n[BBOX READY]",
      "xmin =", bb["xmin"],
      "| ymin =", bb["ymin"],
      "| xmax =", bb["xmax"],
      "| ymax =", bb["ymax"],
      "| time =", Sys.time(),
      "\n"
    )
  }, ignoreInit = TRUE)
  
  # 5️⃣ Leaflet emite bounds (confirma que el mapa EXISTE)
  observeEvent(input$map1_bounds, {
    cat(
      "\n[LEAFLET BOUNDS EMITTED]",
      paste(unlist(input$map1_bounds), collapse = ", "),
      "| time =", Sys.time(),
      "\n"
    )
  }, ignoreInit = TRUE)
  
  # 6️⃣ Sincronización crítica: DOM + datos listos
  observeEvent(
    list(
      session$clientData$output_map1_map_width,
      data_map()
    ),
    {
      cat(
        "\n[TIMING CHECK OK]",
        "width =", session$clientData$output_map1_map_width,
        "| rows =", nrow(data_map()),
        "| time =", Sys.time(),
        "\n"
      )
    },
    ignoreInit = TRUE
  )
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  })
  
  
  
  
  
  
  
  resumen_comunal <- reactive({
    df <- data_map()
    req(nrow(df) > 0)
    
    df %>%
      st_drop_geometry() %>%
      group_by(COMUNA) %>%
      summarise(
        P10 = quantile(escolaridad_disc, 0.10, na.rm = TRUE),
        P90 = quantile(escolaridad_disc, 0.90, na.rm = TRUE),
        .groups = "drop"
      )
  })
  
  # ── MAPA EDUCATIVO ───────────────────────
  mod_map_escolaridad_server(
    "map1",
    manzanas_sf     = data_map,
    resumen_comunal = resumen_comunal,
    modo_seg        = reactive(input$modo_seg)
  )
  

  
  
  
  # ── otros módulos ────────────────────────
  data_excl <- eventReactive(comunas_sel(), {
    manzanas_exclusion %>% filter(COMUNA %in% comunas_sel())
  })
  
  mod_map_exclusion_server("map2", data_excl, comunas_sel)
  mod_indicadores_server("indicadores", data_map)
  mod_comparacion_server("tabla1", data_map)
  
  output$texto_sdi <- renderUI({
    HTML("
  <h3>Social Deprivation Index (SDI)</h3>

  <p>
  El <strong>Social Deprivation Index (SDI)</strong> es un índice sintético diseñado
  para capturar la <strong>privación social multidimensional</strong> a escala
  microterritorial. Su objetivo es identificar territorios donde distintas formas
  de desventaja estructural se acumulan espacialmente, generando condiciones
  persistentes de exclusión.
  </p>

  <p>
  En esta aplicación, el SDI se concibe como un componente analítico central,
  desarrollado para su aplicación sistemática en Chile utilizando
  <strong>exclusivamente datos oficiales del Censo de Población y Vivienda 2024
  (CPV24)</strong>.
  </p>

  <h4>Enfoque conceptual</h4>

  <p>
  El SDI adopta un enfoque <strong>multidimensional</strong> de la privación social,
  entendiendo que la desigualdad territorial no se expresa en una sola variable,
  sino en la combinación simultánea de desventajas educativas, laborales y
  socioeconómicas.
  </p>

  <h4>Dimensiones del índice</h4>

  <p>
  El índice se construye a partir de dimensiones derivadas directamente del CPV24,
  todas calculadas a nivel de <strong>manzana censal</strong>. Entre ellas:
  </p>

  <ul>
    <li>baja escolaridad promedio de la población adulta,</li>
    <li>alta exclusión laboral (desocupación + fuera de la fuerza de trabajo),</li>
    <li>otras dimensiones censales de desventaja social incorporables de forma modular.</li>
  </ul>

  <h4>Construcción del SDI</h4>

  <p>
  Cada dimensión se normaliza para garantizar comparabilidad espacial y luego se
  combina en un <strong>índice sintético</strong> que resume el nivel relativo de
  privación social de cada manzana censal.
  </p>

  <p>
  El proceso prioriza transparencia metodológica, reproducibilidad estadística e
  interpretabilidad sustantiva de los resultados.
  </p>

  <h4>Escala territorial</h4>

  <p>
  El SDI se calcula originalmente a nivel de manzana censal, permitiendo su
  agregación posterior a escalas superiores sin perder información sobre la
  heterogeneidad interna de los territorios.
  </p>

  <h4>Aplicación al contexto chileno</h4>

  <p>
  El SDI está concebido como una <strong>herramienta aplicada</strong> para el
  análisis territorial en Chile, orientada a diagnósticos de desigualdad,
  planificación urbana y focalización de políticas públicas.
  </p>

  <h4>Decisión metodológica</h4>

  <p>
  Al igual que el resto de la aplicación, el SDI ha sido diseñado para
  <strong>no mezclar fuentes estadísticas</strong>. El uso exclusivo del CPV24
  asegura coherencia espacial, auditabilidad metodológica y estabilidad analítica
  en el tiempo.
  </p>

  <p>
  El SDI no se plantea como un ejercicio exploratorio aislado, sino como la base de
  un <strong>instrumento replicable y escalable</strong> para el análisis
  socioespacial de la privación social en Chile.
  </p>
  ")
  })
  
  
  
  # Texto metodología
  output$texto_metodologia <- renderUI({
    HTML("
<h3>Metodología</h3>

<p>
<strong>SocioSpatial Analytics – Chile</strong> es una aplicación Shiny orientada al
análisis socioespacial avanzado que utiliza <strong>exclusivamente datos oficiales
del Censo de Población y Vivienda 2024 (CPV24)</strong>.
</p>

<p>
La aplicación explota simultáneamente la cartografía censal oficial y las variables
socioeconómicas agregadas del propio censo, permitiendo construir indicadores
territoriales directamente sobre la <strong>manzana censal</strong>, la unidad
espacial más fina del sistema estadístico chileno.
</p>

<p>
Este enfoque elimina problemas de incompatibilidad espacial entre fuentes y
garantiza <strong>consistencia estadística, reproducibilidad y trazabilidad
metodológica</strong>.
</p>

<h4>Unidad de análisis</h4>

<p>
El análisis se realiza a nivel de <strong>manzana censal</strong>, evitando
agregaciones comunales o zonales que tienden a ocultar procesos de segregación y
polarización social.
</p>

<p>
Trabajar a esta escala permite identificar:
</p>

<ul>
  <li>guetos socioeducativos,</li>
  <li>enclaves de alta escolaridad,</li>
  <li>bolsas de exclusión laboral,</li>
  <li>gradientes territoriales abruptos dentro de una misma comuna.</li>
</ul>

<h4>Escolaridad</h4>

<p>
La escolaridad se construye a partir de las variables censales del CPV24, calculando
la <strong>escolaridad promedio de la población adulta (18+)</strong> por manzana.
</p>

<p>
Para facilitar la interpretación espacial:
</p>

<ul>
  <li>la escolaridad se discretiza en tramos de <strong>0,5 años</strong>,</li>
  <li>se limita a rangos plausibles para evitar distorsiones visuales,</li>
  <li>se proyecta directamente sobre la geometría censal.</li>
</ul>

<h4>Segregación educativa</h4>

<p>
Para cada comuna se construyen distribuciones completas de escolaridad a nivel de
manzana, a partir de las cuales se calculan:
</p>

<ul>
  <li>percentiles (P10, P25, P50, P75, P90),</li>
  <li>indicadores de segregación (P90 / P10),</li>
  <li>indicadores de polarización (P75 / P25).</li>
</ul>

<p>
Estos indicadores se calculan <strong>exclusivamente con datos del CPV24</strong>,
sin recurrir a encuestas muestrales ni estimaciones indirectas.
</p>

<h4>Exclusión laboral</h4>

<p>
La exclusión laboral se calcula directamente desde variables censales del CPV24,
utilizando conteos poblacionales por manzana:
</p>

<ul>
  <li>población ocupada,</li>
  <li>población desocupada,</li>
  <li>población fuera de la fuerza de trabajo.</li>
</ul>

<p>
A partir de estas variables se estima el <strong>porcentaje de población excluida
del mercado laboral</strong> por manzana, permitiendo mapear territorialmente la
exclusión con <strong>alta precisión microespacial</strong>.
</p>

<h4>Visualización</h4>

<p>
La aplicación combina:
</p>

<ul>
  <li>mapas interactivos a nivel de manzana,</li>
  <li>capas temáticas dinámicas,</li>
  <li>indicadores comunales derivados de microdatos.</li>
</ul>

<p>
Los mapas permiten alternar entre:
</p>

<ul>
  <li>niveles absolutos,</li>
  <li>categorías territoriales,</li>
  <li>extremos de la distribución,</li>
</ul>

<p>
revelando patrones de segregación invisibles en análisis territoriales
tradicionales.
</p>

<h4>Decisión metodológica clave</h4>

<p>
La aplicación fue diseñada deliberadamente para <strong>no mezclar fuentes
estadísticas</strong>.
</p>

<p>
El uso exclusivo del CPV24:
</p>

<ul>
  <li>evita errores de alineación espacial,</li>
  <li>elimina supuestos de expansión muestral,</li>
  <li>asegura coherencia interna entre geometría y variables,</li>
  <li>facilita auditoría metodológica.</li>
</ul>

<h4>Arquitectura y despliegue</h4>

<p>
La aplicación está desarrollada en <strong>Shiny (R)</strong> y diseñada bajo un
enfoque <strong>DevOps-first</strong>:
</p>

<ul>
  <li>estructura modular,</li>
  <li>separación estricta entre lógica, datos y visualización,</li>
  <li>contenedorización con Docker,</li>
  <li>entorno reproducible y portable.</li>
</ul>

<p>
La contenedorización no es un agregado posterior, sino una
<strong>decisión arquitectónica</strong> que guía el diseño del código, los datos y
el ciclo de vida del despliegue.
</p>
")
    
  })
  
}

shinyApp(ui, server)



