if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# Cargamos la base recorridos_barrios (creada en el script 08):
recorridos_barrios <- read.csv("data/processed/recorridos_barrios.csv")

# Creamos una dummy del género femenino y una variable para señalar el momento
# del día:
datos_graf <- recorridos_barrios %>%
  mutate(
    es_mujer = ifelse(genero == "FEMALE", 1, 0),
    periodo = ifelse(es_noche == "Sí", "Noche", "Día")
  ) %>%
  group_by(comuna, periodo) %>%
  summarise(prop_mujeres = mean(es_mujer) * 100, .groups = "drop")

# Gráfico de barras con proporciones para día y noche:
graf2 <- ggplot(datos_graf, aes(x = reorder(factor(comuna), -prop_mujeres), 
                                y = prop_mujeres, fill = periodo)) +
  geom_col(position = "dodge", alpha = 0.85, width = 0.7) +
  scale_fill_manual(values = c("Día" = "#56B4D3", "Noche" = "#084C61"), name = "Período") +
  geom_text(aes(label = paste0(round(prop_mujeres, 1), "%")), 
            position = position_dodge(width = 0.7),
            vjust = -0.6, size = 2.5, color = "gray30") +
  labs(
    title = "Uso de Ecobici por mujeres: comparación día-noche por comuna",
    subtitle = "Porcentaje de viajes realizados por mujeres según período del día (CABA, 2024)",
    x = "Comuna",
    y = "Porcentaje de viajes realizados por mujeres (%)",
    caption = "Fuente: GCBA, 2024"
  ) +
  theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(face = "bold", size = 22, hjust = 0.5, margin = margin(b = 8)),
    plot.subtitle = element_text(size = 16, color = "gray40", hjust = 0.5, margin = margin(b = 20)),
    plot.caption = element_text(size = 12, color = "gray50", hjust = 0.5, margin = margin(t = 20)),
    axis.title.x = element_text(face = "bold", size = 14, margin = margin(t = 10)),
    axis.title.y = element_text(face = "bold", size = 14, margin = margin(r = 10)),
    axis.text.x = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(face = "bold", size = 14),
    legend.text = element_text(size = 13),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.margin = margin(25, 25, 25, 25),
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA)
   ) +
  ylim(0, max(datos_graf$prop_mujeres) * 1.20)

print(graf2)

ggsave("output/figures/grafico2_cambio_dia_noche_por_comuna.png", 
       plot = graf2, width = 12, height = 7, dpi = 300)
