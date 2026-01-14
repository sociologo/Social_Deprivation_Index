mod_comparacion_ui <- function(id) {
  ns <- NS(id)
  DT::DTOutput(ns("tabla"))
}

mod_comparacion_server <- function(id, data) {
  
  moduleServer(id, function(input, output, session) {
    
    output$tabla <- DT::renderDT({
      resumen <- get_resumen_comunal(data())
      
      DT::datatable(
        resumen,
        rownames = FALSE,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          columnDefs = list(
            list(className = "dt-right", targets = 1:12),
            list(
              render = DT::JS(
                "function(data, type, row, meta) {
             if (type === 'display' && data !== null && !isNaN(data)) {
               return Number(data).toFixed(3);
             }
             return data;
           }"
              ),
              targets = 2:12
            )
          )
        ),
        colnames = c(
          "Comuna",
          "Manzanas",
          "Promedio",
          "Desviación",
          "Mínimo",
          "Máximo",
          "P10",
          "P25",
          "Mediana",
          "P75",
          "P90",
          "Segregación (P90/P10)",
          "Polarización (P75/P25)"
        )
      )
    })
  })
}
