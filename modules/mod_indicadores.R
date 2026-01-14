mod_indicadores_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    div(
      class = "kpi-grid",
      
      # =========================
      # Escolaridad promedio
      # =========================
      div(
        id = ns("kpi_mean"),
        class = "kpi-card",
        
        div(class = "kpi-title",
            span("Escolaridad promedio"),
            span("ℹ️", class = "kpi-info")
        ),
        
        div(class = "kpi-value", textOutput(ns("mean"))),
        div(class = "kpi-help", "Años de estudio"),
        
        div(
          class = "kpi-tooltip",
          strong("¿Qué mide?"), br(),
          "Promedio de años de escolaridad de la población adulta (18+) ",
          "en las manzanas seleccionadas."
        )
      ),
      
      # =========================
      # Desviación
      # =========================
      div(
        id = ns("kpi_sd"),
        class = "kpi-card",
        
        div(class = "kpi-title",
            span("Desviación"),
            span("ℹ️", class = "kpi-info")
        ),
        
        div(class = "kpi-value", textOutput(ns("sd"))),
        div(class = "kpi-help", "Dispersión"),
        
        div(
          class = "kpi-tooltip",
          strong("¿Qué mide?"), br(),
          "Nivel de heterogeneidad de la escolaridad entre manzanas."
        )
      ),
      
      # =========================
      # Gueto educativo
      # =========================
      div(
        id = ns("kpi_gueto"),
        class = "kpi-card",
        
        div(class = "kpi-title",
            span("Gueto educativo"),
            span("ℹ️", class = "kpi-info")
        ),
        
        div(class = "kpi-value", textOutput(ns("gueto"))),
        div(class = "kpi-help", "10% inferior"),
        
        div(
          class = "kpi-tooltip",
          strong("¿Qué mide?"), br(),
          "Porcentaje de manzanas ubicadas en el 10% inferior ",
          "de la distribución de escolaridad."
        )
      ),
      
      # =========================
      # Clase elite
      # =========================
      div(
        id = ns("kpi_elite"),
        class = "kpi-card",
        
        div(class = "kpi-title",
            span("Clase elite"),
            span("ℹ️", class = "kpi-info")
        ),
        
        div(class = "kpi-value", textOutput(ns("elite"))),
        div(class = "kpi-help", "10% superior"),
        
        div(
          class = "kpi-tooltip",
          strong("¿Qué mide?"), br(),
          "Porcentaje de manzanas ubicadas en el 10% superior ",
          "de la distribución de escolaridad."
        )
      ),
      
      # =========================
      # Índice de segregación
      # =========================
      div(
        id = ns("kpi_indice"),
        class = "kpi-card",
        
        div(class = "kpi-title",
            span("Índice de segregación"),
            span("ℹ️", class = "kpi-info")
        ),
        
        div(class = "kpi-value", textOutput(ns("indice"))),
        div(class = "kpi-help", "Brecha social"),
        
        div(
          class = "kpi-tooltip",
          strong("¿Qué mide?"), br(),
          "Razón entre el percentil 90 y el percentil 10 (P90 / P10). ",
          "Indica la distancia social entre élites y guetos educativos."
        )
      )
    ),
    
    hr(),
    uiOutput(ns("frase"))
  )
}


mod_indicadores_server <- function(id, data) {
  
  moduleServer(id, function(input, output, session) {
    
    safe <- reactive({
      df <- data()
      if (is.null(df) || nrow(df) == 0) return(NULL)
      df
    })
    
    output$mean <- renderText({
      df <- safe()
      if (is.null(df)) return("–")
      round(mean(df$escolaridad_disc, na.rm = TRUE), 2)
    })
    
    output$sd <- renderText({
      df <- safe()
      if (is.null(df)) return("–")
      round(sd(df$escolaridad_disc, na.rm = TRUE), 2)
    })
    
    universo <- reactive({
      df <- safe()
      if (is.null(df)) return(NULL)
      dplyr::filter(df, escolaridad_disc > 8.5)
    })
    
    p10_activo <- reactive({
      u <- universo()
      if (is.null(u) || nrow(u) == 0) return(NA_real_)
      quantile(u$escolaridad_disc, 0.10, na.rm = TRUE)
    })
    
    p90_activo <- reactive({
      u <- universo()
      if (is.null(u) || nrow(u) == 0) return(NA_real_)
      quantile(u$escolaridad_disc, 0.90, na.rm = TRUE)
    })
    
    output$gueto <- renderText({
      u <- universo()
      p10 <- p10_activo()
      if (is.null(u) || is.na(p10)) return("–")
      paste0(round(mean(u$escolaridad_disc <= p10) * 100, 1), "%")
    })
    
    output$elite <- renderText({
      u <- universo()
      p90 <- p90_activo()
      if (is.null(u) || is.na(p90)) return("–")
      paste0(round(mean(u$escolaridad_disc >= p90) * 100, 1), "%")
    })
    
    output$indice <- renderText({
      p10 <- p10_activo()
      p90 <- p90_activo()
      if (is.na(p10) || is.na(p90)) return("–")
      round(p90 / p10, 2)
    })
    
    output$frase <- renderUI({
      u <- universo()
      if (is.null(u) || nrow(u) == 0) return(NULL)
      
      p10 <- p10_activo()
      p90 <- p90_activo()
      
      gueto <- mean(u$escolaridad_disc <= p10) * 100
      elite <- mean(u$escolaridad_disc >= p90) * 100
      seg <- p90 / p10
      
      n_comunas <- length(unique(safe()$COMUNA))
      sujeto <- if (n_comunas == 1) "la comuna seleccionada" else "las comunas seleccionadas"
      
      HTML(paste0(
        "<div class='insight-text'>",
        "En ", sujeto,
        ", el <b>", round(gueto,1), "%</b> de las manzanas está en el ",
        "<b>10% inferior</b> de escolaridad y el <b>", round(elite,1),
        "%</b> en el <b>10% superior</b>; ",
        "la brecha social es de <b>", round(seg,2), "×</b>.",
        "</div>"
      ))
    })
    
  })
}
