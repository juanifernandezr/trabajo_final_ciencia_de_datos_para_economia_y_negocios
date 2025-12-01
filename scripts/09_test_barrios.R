if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, gt, webshot2)

# Quitamos la notación científica:
options(scipen = 999)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# Cargamos la base a utilizar y creamos una tabla:
recorridos_genero_barrios <- read_csv("data/processed/recorridos_barrios.csv", 
                               col_select = c(genero, comuna)
                               )

tabla_comuna_genero <- table(recorridos_genero_barrios$comuna, recorridos_genero_barrios$genero)

# Realizamos un test de independencia entre comuna y género:
test_chi <- chisq.test(tabla_comuna_genero)
print(test_chi)

# Creamos una tabla con la proporción de viajes realizados por mujeres en cada comuna:
resumen_prop <- recorridos_genero_barrios %>%
  group_by(comuna) %>%
  summarise(
    total_viajes = n(),
    mujeres = sum(genero == "FEMALE"),
    hombres = sum(genero == "MALE"),
    prop_mujeres = mujeres / total_viajes,
    .groups = 'drop'
  ) %>%
  arrange(desc(prop_mujeres))

# Creamos un gráfico y tablas:
grafico_prop <- ggplot(resumen_prop, aes(x = factor(comuna), y = prop_mujeres)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Proporción de mujeres por comuna de origen del viaje",
       x = "Comuna", y = "Proporción de mujeres") +
  theme_minimal()

ggsave("output/figures/proporcion_mujeres_por_comuna.jpeg", plot = grafico_prop, width = 8, height = 6, dpi = 300)

gt_prop <- gt(resumen_prop) %>%
  tab_header(title = "Proporción de mujeres por comuna") %>%
  cols_label(
    comuna = "Comuna", total_viajes = "Total viajes",
    mujeres = "Mujeres", hombres = "Hombres", prop_mujeres = "Proporción"
  ) %>%
  fmt_number(columns = prop_mujeres, decimals = 3) %>%
  cols_align(align = "center", columns = everything())

gtsave(gt_prop, "output/tables/proporcion_mujeres_comuna.png")

resultados_test_chi <- data.frame(
  estadistico = round(as.numeric(test_chi$statistic), 2),
  p_valor = format.pval(test_chi$p.value, digits = 4),
  grados_libertad = as.numeric(test_chi$parameter),
  decision = ifelse(test_chi$p.value < 0.05, "Rechazo H0", "No rechazo H0")
)

gt_chi <- gt(resultados_test_chi) %>%
  tab_header(title = "Test Chi-cuadrado") %>%
  cols_label(
    estadistico = "Estadístico", p_valor = "p-valor",
    grados_libertad = "Grados de libertad", decision = "Decisión"
  ) %>%
  cols_align(align = "center", columns = everything())

gtsave(gt_chi, "output/tables/test_chi_cuadrado_comuna.png")
