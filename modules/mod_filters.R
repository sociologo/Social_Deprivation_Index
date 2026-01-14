mod_filters_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    selectInput(
      ns("comunas"),
      "Seleccione comunas",
      choices = NULL,
      selected = "SANTIAGO",
      multiple = TRUE
    )
  )
}

mod_filters_server <- function(id) {
  
  moduleServer(id, function(input, output, session) {
    
    updateSelectInput(
      session,
      "comunas",
      choices = sort(unique(manzanas$COMUNA)),
      selected = "SANTIAGO"
    )
    
    reactive({
      input$comunas
    })
  })
}