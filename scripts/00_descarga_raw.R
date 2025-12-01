# Script 00: Descarga y guardado de bases de datos.
# Descargamos bases de datos de usuarios y recorridos de Ecobici y guardarlas como csv en data/raw/.

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse)

# Creamos el directorio data/raw en caso de que no exista:
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

usuarios <- read_csv("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/transporte-y-obras-publicas/bicicletas-publicas/usuarios_ecobici_2024.csv")

# Para descargar la base con los recorridos, debido a su gran tamaño, debemos
# establecer un tiempo máximo de descarga superior a los 60 segundos.Además, 
# debido a que es un zip, lo guardamos de forma temporal para luego poder leer 
# el csv contenido en el mismo.
options(timeout = 600)

z <- tempfile()
download.file("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/transporte-y-obras-publicas/bicicletas-publicas/recorridos-realizados-2024.zip", 
              z, mode = "wb")
recorridos <- read_csv(unz(z, "badata_ecobici_recorridos_realizados_2024.csv"))
unlink(z)

# Descargamos una base con barrios de la Ciudad, con su delimitación geográfica,
# para utilizar en el script 07:
barrios <- read_csv('https://cdn.buenosaires.gob.ar/datosabiertos/datasets/innovacion-transformacion-digital/barrios/barrios.csv',
              # Seleccionamos aquellas variables que serán de interés:
              col_select = c(id, nombre, comuna, geometry))

write_csv(usuarios, "data/raw/usuarios_ecobici_2024.csv")
write_csv(recorridos, "data/raw/recorridos_2024.csv")
write_csv(barrios, "data/raw/barrios.csv")
