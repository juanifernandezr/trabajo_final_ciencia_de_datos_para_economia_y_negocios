# Script Master - Ejecuta todos los scripts

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

source("scripts/00_descarga_raw.R")
source("scripts/01_limpieza.R")
source("scripts/02_datos_auxiliares.R")
source("scripts/03_estadisticas_descriptivas.R")
source("scripts/04_estadisticas_descriptivas_outliers.R")
source("scripts/05_dummy_noche.R")
source("scripts/06_test_proporciones.R")
source("scripts/07_estaciones_barrio.R")
source("scripts/08_recorridos_barrios.R")
source("scripts/09_test_barrios.R")
source("scripts/10_regresion_logistica.R")
source("scripts/11_grafico.R")
source("scripts/12_grafico_2.R")