# Script 01: Limpieza y transformación de datos
# Objetivo: Limpiar datos crudos y generar dataset procesado.

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, lubridate)

# Creamos el directorio data/clean en caso de que no exista:
dir.create("data/clean", recursive = TRUE, showWarnings = FALSE)

recorridos <- read_csv("data/raw/recorridos_2024.csv")

# Creamos la variable es circular para señalar aquellos viajes que inician y 
# terminan en la misma estación. Por otro lado, separamos las fechas en 2 variables: 
# una que contenga año, mes y día, y otra con horas y minutos.
recorridos_clean <- recorridos %>%
  mutate(
    es_circular = ifelse(id_estacion_origen == id_estacion_destino, "Sí", "No"),
    fecha_origen = as.Date(fecha_origen_recorrido),
    hora_origen = format(fecha_origen_recorrido, "%H:%M"),
    fecha_destino = as.Date(fecha_destino_recorrido),
    hora_destino = format(fecha_destino_recorrido, "%H:%M")
  ) %>%
    # Seleccionamos las variables de interés:
  select(duracion_recorrido, fecha_origen, hora_origen, fecha_destino, 
         hora_destino, genero, es_circular, id_estacion_origen) %>%
  # Conservamos solo los viajes con una duración menor a las 4 horas. Si el viaje
  # es circular conservamos solo aquellos de más de 3 minutos. Si no es circular,
  # el límite inferior es de 2 minutos. Además, quitamos los NAs y los viajes 
  # realizados por usuarios de género OTHER.
  filter(
    (es_circular == "Sí" & duracion_recorrido > 180 & duracion_recorrido < 14400) |
      (es_circular == "No" & duracion_recorrido > 120 & duracion_recorrido < 14400),
    if_all(everything(), ~ !is.na(.)),
    genero != "OTHER"
  )

write_csv(recorridos_clean, "data/clean/recorridos_clean.csv")