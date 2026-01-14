# Socio-Spatial Analytics Chile  
### CASEN 2022 / 2024 · R Shiny Application

## Overview

This repository contains a **production-ready R Shiny application** for **socio-spatial analysis of social indicators in Chile**, built on **CASEN 2022/2024** survey data and **census cartography**.

The project is designed with a **clean architecture, modular Shiny structure, reproducible environment, and deployment readiness**, following best practices expected in professional data science and analytics teams.

---

## Key Features

- 📊 Interactive socio-spatial dashboards  
- 🗺️ Territorial analysis using census cartography  
- 🎓 Education and labor segregation indicators  
- ⚙️ Modular Shiny architecture for scalability  
- 🔁 Fully reproducible R environment (`renv`)  
- 🚀 Ready for deployment (`shinyapps.io` / Shiny Server)

---

## Project Architecture

### Core Application

```text
app.R        # Single entry point (deployment-friendly)
global.R     # Global configuration, shared objects, data loading
modules/     # Shiny modules (scalable, maintainable architecture)
www/         # Static assets (CSS, JS, images)

✔️ Single entry point simplifies deployment

✔️ Explicit modularization supports scalability and team development

Data & Spatial Layer

data/        # Processed, lightweight analytical datasets
geo/         # Spatial objects (sf-compatible)

Raw census cartography (.gdb) is intentionally excluded from Git

Heavy and non-portable sources are used only for preprocessing

The repository contains optimized, portable objects:

.rds

.qs

.gpkg

This ensures fast startup, portability, and clean version control.

Reproducibility & Environment Management

renv/
renv.lock    # Locked dependency graph
.Rprofile    # Automatic renv bootstrap
.gitignore   # Clean separation of code vs artifacts

✔️ Fully reproducible R environment

✔️ Deterministic dependency resolution

✔️ Production-grade setup for collaboration and deployment

Technology Stack

R

Shiny

sf / spatial data

renv

Git / GitHub

Shinyapps.io (deployment-ready)

Typical Use Cases

Socio-territorial diagnostics

Municipal and regional analysis

Education and labor market segmentation

Policy-oriented dashboards

Applied academic research

Author

Developed by a sociologist and data analyst/programmer, combining:

Quantitative social science

Applied territorial analysis

Production-grade R and Shiny engineering
