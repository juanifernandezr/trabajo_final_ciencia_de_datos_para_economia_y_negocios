if (!require("pacman")) install.packages("pacman")
pacman::p_load(sf, tidyverse)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# Cargamos la base con los barrios (y su comuna) de la Ciudad, con su correpondiente
# delimitación geográfica. Además, cargamos la base de recorridos, pero solo 
# conservamos las columnas con el id de la estación de origen, latitud y longitud.
estaciones <- read_csv("data/raw/recorridos_2024.csv",
              col_select = c(id_estacion_origen, long_estacion_origen, lat_estacion_origen)) %>%
                distinct()
              
                        
barrios <- read_csv("data/raw/barrios.csv")

# Convertimos las estaciones en puntos espaciales:
estaciones_sf <- st_as_sf(estaciones, coords = c("long_estacion_origen", "lat_estacion_origen"), crs = 4326, remove = TRUE)

# Convertimos a la base de barrios en un objeto espacial. WKT es el formato de 
# la columna geometry.
barrios_sf <- st_as_sf(barrios, wkt = "geometry", crs = 4326)
# En caso de que hubiese errores en los polígonos, esta línea los corrige:
barrios_sf <- st_make_valid(barrios_sf)

# Realizamos un join entre las 2 nuevas bases. Le asigna a cada estación el
# barrio donde se encuentra.
estaciones_con_barrio <- st_join(estaciones_sf, barrios_sf, join = st_intersects, left = TRUE) %>%
  # En caso de que, por algún error en las coordenadas, el punto no se encuentre
  # exactamente dentro de ningún barrio, le asignamos el más cercano:
  mutate(
    id = if_else(
      is.na(id),
      barrios_sf$id[ st_nearest_feature(., barrios_sf) ],
      id
    ),
    nombre = if_else(
      is.na(nombre),
      barrios_sf$nombre[ st_nearest_feature(., barrios_sf) ],
      nombre
    ),
    comuna = if_else(
      is.na(comuna),
      barrios_sf$comuna[ st_nearest_feature(., barrios_sf) ],
      comuna
    )
  )%>%
  st_drop_geometry()

write_csv(estaciones_con_barrio, "data/processed/estaciones_con_barrio.csv")