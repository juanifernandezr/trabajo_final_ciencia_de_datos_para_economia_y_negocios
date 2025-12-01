if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, DescTools, gt, webshot2)

# Quitamos la notación científica:
options(scipen = 999)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# Filtramos la base para conservar solo los viajes de menos de 2 horas.
recorridos_clean_outliers <- read.csv("data/clean/recorridos_clean.csv") %>%
  filter(duracion_recorrido < 7200)

# Traducimos al español los valores de genero. Calculamos estadísticas descriptivas
# para hombres y mujeres:
recorridos_clean_outliers_estadistica <- recorridos_clean_outliers %>%
  mutate(
    genero = case_when(
      genero == "FEMALE" ~ "Femenino",
      genero == "MALE" ~ "Masculino"
    )
  ) %>%
  group_by(genero) %>%
  # Dividimos la duración del recorrido por 60 para obtener valores en minutos:
  summarise(
    obs = n(),
    media = mean(duracion_recorrido/60),
    mediana = median(duracion_recorrido/60),
    moda = Mode(duracion_recorrido/60),
    desvio_std = sd(duracion_recorrido/60),
    rango_iqr = IQR(duracion_recorrido/60)
  )

print(recorridos_clean_outliers_estadistica)

# Generamos el gráfico de densidad y lo guardamos:
graf_densidad <- ggplot(recorridos_clean_outliers, aes(x = duracion_recorrido, color = genero)) +
  geom_density(linewidth = 1.1) +
  labs(x = "Duración del recorrido", y = "Densidad", color = "Género") +
  scale_color_manual(
    values = c("FEMALE" = "#F8766D", "MALE" = "#00BFC4"),
    labels = c("FEMALE" = "Femenino", "MALE" = "Masculino")
  ) +
  theme_classic(base_size = 14) +
  theme(
    panel.background = element_rect(fill = NA, colour = NA),
    plot.background  = element_rect(fill = NA, colour = NA),
    legend.background = element_rect(fill = NA, colour = NA),
    legend.key = element_rect(fill = NA, colour = NA)
  )

ggsave("output/figures/grafico_densidad_outliers.png", plot = graf_densidad, width = 8, height = 5, dpi = 300)

# Generamos el boxplot y lo guardamos:
png("output/figures/boxplot_outliers.jpg", width = 1600, height = 1200, res = 150, bg = "transparent")
boxplot(recorridos_clean_outliers$duracion_recorrido)
dev.off()

# Guardamos la tabla con las estadísticas calculadas:
gt_tabla <- gt(recorridos_clean_outliers_estadistica) %>%
  cols_label(
    genero = "Género",
    obs = "Observaciones",
    media = "Media",
    mediana = "Mediana",
    moda = "Moda",
    desvio_std = "Desvío estándar",
    rango_iqr = "Rango IQR"
  ) %>%
  cols_align(
    align = "center",
    columns = everything()
  )

gtsave(gt_tabla, "output/tables/estadisticas_descriptivas_outliers.png")

write_csv(recorridos_clean_outliers, "data/processed/recorridos_clean_outliers.csv")