# Social Deprivation Index (SDI) in Chile  

Christian Castro

c.castro.n@proton.me

### CENSO 2024 · R Shiny Application

## Overview

This repository contains a **production-ready R Shiny application** for **socio-spatial analysis of social indicators in Chile**, built on **CENSO 2024** survey data and **census cartography**.

The project is designed with a **clean architecture, modular Shiny structure, reproducible environment, and deployment readiness**.

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

- **app.R**        # Single entry point (deployment-friendly)
- **global.R**     # Global configuration, shared objects, data loading
- **modules/**     # Shiny modules (scalable, maintainable architecture)
- **www/**         # Static assets (CSS, JS, images)

- ✔️ Single entry point simplifies deployment
- ✔️ Explicit modularization supports scalability and team development

Data & Spatial Layer

- **data/**        # Processed, lightweight analytical datasets
- **geo/**         # Spatial objects (sf-compatible)

**Raw census cartography (.gdb) is intentionally excluded from Git**

Heavy and non-portable sources are used only for preprocessing

The repository contains optimized, portable objects:

- .rds
- .qs
- .gpkg

This ensures fast startup, portability, and clean version control.

Reproducibility & Environment Management

- renv/
- renv.lock    # Locked dependency graph
- .Rprofile    # Automatic renv bootstrap
- .gitignore   # Clean separation of code vs artifacts

- ✔️ Fully reproducible R environment
- ✔️ Deterministic dependency resolution
- ✔️ Production-grade setup for collaboration and deployment

## 🧰 Technology Stack

The application is built using a modern and robust analytics stack:

- **R** — statistical computing and data analysis  
- **Shiny** — interactive web applications  
- **sf** — spatial data handling and geospatial analysis  
- **renv** — reproducible dependency management  
- **Git / GitHub** — version control and collaboration  
- **Shinyapps.io** — production-ready deployment platform  



## 🎯 Typical Use Cases

This project is suitable for a wide range of applied analytical contexts, including:

- **Socio-territorial diagnostics**
- **Municipal and regional analysis**
- **Education and labor market segmentation**
- **Policy-oriented analytical dashboards**
- **Applied academic and institutional research**

---

## 👤 Author

Developed by a **sociologist and data analyst/programmer**, combining:

- Quantitative social science expertise  
- Applied territorial and spatial analysis  
- Production-grade R and Shiny engineering  

