if (!require("pacman")) install.packages("pacman")
pacman::p_load(sf, tidyverse)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# Cargamos la base con los datos de los barrios. Transformamos al data frame en 
# un objeto espacial y arreglamos los errores que pueda haber en los polígonos:
barrios <- read_csv("data/raw/barrios.csv")
barrios_sf <- st_as_sf(barrios, wkt = "geometry", crs = 4326)
barrios_sf <- st_make_valid(barrios_sf)

# Unimos los polígonos de los barrios para obtener un polígono que represente
# a cada comuna:
comunas_sf <- barrios_sf %>%
  group_by(comuna) %>%
  summarise(geometry = st_union(geometry))

# Cargamos la base recorridos_barrios (creada en el script 08):
recorridos_barrios <- read_csv("data/processed/recorridos_barrios.csv")

# Creamos una dummy del género femenino, una variable para señalar el momento
# del día y otra para calcular la diferencia entre la proporción de viajes de 
# mujeres de noche y de día:
diferencia_dia_noche <- recorridos_barrios %>%
  mutate(
    es_mujer = ifelse(genero == "FEMALE", 1, 0),
    periodo = ifelse(es_noche == "Sí", "Noche", "Día")
  ) %>%
  group_by(comuna, periodo) %>%
  summarise(prop_mujeres = mean(es_mujer) * 100, .groups = "drop") %>%
  pivot_wider(names_from = periodo, values_from = prop_mujeres) %>%
  mutate(diferencia = Noche - Día)

# Realizamos un left join entre el data frame con los datos geográficos de las 
# comunas y la variable de diferencia de proporciones recién calculada:
mapa_datos <- comunas_sf %>%
  left_join(diferencia_dia_noche, by = "comuna")

# Mapa de CABA con diferencia de proporciones:
graf1 <- ggplot(mapa_datos) +
  geom_sf(aes(fill = diferencia), color = "white", size = 1.2) +
  scale_fill_gradient(low = "#084C61", high = "#C8E6F5",
                      name = "Diferencia\n(pp)",
                      breaks = seq(-6, 0, 2)) +
  geom_sf_text(aes(label = paste0(comuna, "\n",
                                  ifelse(diferencia > 0, "+", ""),
                                  round(diferencia, 1), "pp")),
               size = 5.5, fontface = "bold", color = "white") +
  labs(
    title = "Viajes de mujeres en Ecobici: caída durante la noche por comuna",
    subtitle = "Diferencia en puntos porcentuales entre noche y día (CABA, 2024)",
    caption = "Fuente: GCBA, 2024\nColores más oscuros indican mayor caída del uso por parte de mujeres durante la noche"
  ) +
  theme_void(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold", size = 25, hjust = 0.5),
    plot.subtitle = element_text(size = 18, color = "gray40", hjust = 0.5),
    plot.caption = element_text(size = 16, color = "gray50", hjust = 0.5),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.margin = margin(25, 25, 25, 25),
    legend.key.height = unit(1.5, "cm")
  )

ggsave("output/figures/grafico1_mapa_diferencia_dia_noche.png",
       graf1, width = 11, height = 11, dpi = 300)
