
# global.R NO ejecuta lógica ni crea datos, 
# solo define dependencias y funciones.





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

source("modules/mod_map_exclusion_laboral.R")
source("modules/mod_comparacion.R")
source("R/load_data.R")
source("R/maps.R")
source("R/palettes.R")
source("R/indicators.R")
source("R/filters.R")
source("modules/mod_map_escolaridad.R")
source("modules/mod_filters.R")
source("modules/mod_indicadores.R")
# source("R/init_data.R")

manzanas <- load_all_data()


