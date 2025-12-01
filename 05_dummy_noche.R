if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, lubridate)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Cargamos la base con los viajes de menos de 2 horas y la que contiene la salida
# y puesta del sol de todo 2024:
recorridos_clean_outliers <- read_csv("data/processed/recorridos_clean_outliers.csv")
salida_puesta_sol <- read_csv("data/processed/salida_puesta_sol.csv")

# Realizamos un left join entre ambas tomando de referencia la variable fecha_origen:
recorridos_dia_noche <- left_join(recorridos_clean_outliers, salida_puesta_sol, by = "fecha_origen") %>%
  mutate(
    es_noche = case_when(
      hora_origen < salida | hora_origen > puesta ~ "Sí",
      hora_destino > (puesta + dminutes(30)) ~ "Sí",
      TRUE ~ "No"
    )
  )

write_csv(recorridos_dia_noche, "data/processed/recorridos_dia_noche.csv")