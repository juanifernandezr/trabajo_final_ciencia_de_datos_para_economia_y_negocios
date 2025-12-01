if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Cargamos la base con los datos de estaciones y barrios, y la base con los 
# recorridos clasificados entre diurnos y nocturnos.
estaciones_con_barrio <- read_csv("data/processed/estaciones_con_barrio.csv")
recorridos_dia_noche <- read_csv("data/processed/recorridos_dia_noche.csv")

# Realizamos un left join entre ambas bases, tomando como referencia la columna
# del id de la estación de origen:
recorridos_barrios <- recorridos_dia_noche %>%
  left_join(estaciones_con_barrio, by = "id_estacion_origen")

write_csv(recorridos_barrios, "data/processed/recorridos_barrios.csv")