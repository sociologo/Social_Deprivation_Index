FROM rocker/geospatial:4.4.1

# ── paquetes R que NO vienen en geospatial ──
RUN R -e "install.packages(c( \
  'shiny', \
  'shinyjs', \
  'shinycssloaders', \
  'bslib', \
  'bsicons', \
  'DT', \
  'dplyr', \
  'survey', \
  'haven', \
  'shinydashboard', \
  'jsonlite' \
), repos='https://cloud.r-project.org')"

# ── copiar app ──
COPY . /srv/shiny-server/censo

# ── permisos correctos ──
RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
