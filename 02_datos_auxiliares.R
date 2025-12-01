if (!require("pacman")) install.packages("pacman")
pacman::p_load(rvest, httr, tidyverse, lubridate)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos el directorio data/processed en caso de que no exista:
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

mes_vals <- c("Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic")

# Descargamos desde el SHN las tablas mensuales de salida y puesta del sol:
get_mes <- function(mes_num){
  url_form <- "https://www.hidro.gov.ar/Observatorio/Astronomia.asp?op=1"
  pg <- read_html(url_form)
  csrf <- pg %>% html_element("input[name='CSRFToken']") %>% html_attr("value")
  
  res <- POST(
    url = "https://www.hidro.gov.ar/Observatorio/REsol.asp",
    body = list(
      CSRFToken = csrf,
      Localidad = "BUENOS AIRES",
      Mes = mes_vals[mes_num],
      Fanio = "2024"
    ),
    encode = "form"
  )
  
  html_res <- read_html(res)
  tabla <- html_res %>% html_table() %>% .[[1]]
  
  tabla_limpia <- tabla %>%
    transmute(
      dia = as.integer(`Día del mes`),
      salida = `Salida`,
      puesta = `Puesta`,
      fecha_origen = ymd(sprintf("2024-%02d-%02d", mes_num, dia))
    ) %>%
    select(fecha_origen, salida, puesta)
  
  return(tabla_limpia)
}

# Combinamos los datos de todos los meses en un data frame:
salida_puesta_sol <- map_dfr(1:12, get_mes)

write_csv(salida_puesta_sol, "data/processed/salida_puesta_sol.csv")
