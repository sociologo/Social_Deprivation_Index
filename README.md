# CASEN 2024 – App Shiny

Aplicación Shiny para visualización y análisis territorial de indicadores
sociales a partir de CASEN 2022/2024 y cartografía censal.

## Estructura
- `app.R` – app principal
- `global.R` – carga de datos y funciones globales
- `modules/` – módulos Shiny
- `R/` – funciones auxiliares
- `www/` – JS y CSS
- `data/` – datos procesados (no versionados)
- `geo/` – cartografía local (no versionada)

## Requisitos
- R >= 4.3
- shiny
- sf
- dplyr
- ggplot2

## Ejecución local
```r
shiny::runApp()
