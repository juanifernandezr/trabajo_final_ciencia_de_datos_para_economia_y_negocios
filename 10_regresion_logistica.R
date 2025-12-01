if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, broom, gt, webshot2, marginaleffects)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# Cargamos la base recorridos_barrios (creada en el script 08):
recorridos_barrios <- read_csv("data/processed/recorridos_barrios.csv")

# Creamos una dummy para el género femenino y hacemos que comuna sea considerada
# como una variable categórica:
recorridos_genero_comuna <- recorridos_barrios %>%
  mutate(
    comuna = factor(comuna),
    es_mujer = if_else(genero == "FEMALE", 1, 0)
    ) %>%
  select(comuna, es_noche, es_mujer)

# Cramos un modelo logit:
modelo_logit <- glm(es_mujer ~ comuna * es_noche, data = recorridos_genero_comuna, family = binomial(link = "logit"))
print(summary(modelo_logit))

# Intentamos usar efectos marginales, pero era un cálculo demasiado exigente para
# nuestras computadoras.

# Realizamos un ANOVA:
anova_modelo <- anova(modelo_logit, test = "Chisq")
print(anova_modelo)

resumen_genero_comuna <- recorridos_genero_comuna %>%
  group_by(comuna, es_noche) %>%
  summarise(
    total = n(),
    mujeres = sum(es_mujer),
    prop_mujeres = mean(es_mujer),
    .groups = "drop"
  ) %>%
  arrange(comuna, es_noche)

resumen_noche <- recorridos_genero_comuna %>%
  group_by(es_noche) %>%
  summarise(
    total = n(),
    mujeres = sum(es_mujer),
    prop_mujeres = mean(es_mujer)
  )

coeficientes <- tidy(modelo_logit) %>%
  select(term, estimate, std.error, statistic, p.value)

# Creamos dos tablas con los coeficientes del modelo logit:
gt_logit <- coeficientes %>%
  filter(!grepl("comuna[0-9]+:es_nocheSí", term)) %>%
  gt() %>%
  tab_header(title = "Coeficientes del modelo logit") %>%
  cols_label(
    term = "Término",
    estimate = "Estimación",
    std.error = "Error Std",
    statistic = "Estadístico Z",
    p.value = "p-valor"
  ) %>%
  fmt_number(columns = c(estimate, std.error, statistic), decimals = 4) %>%
  fmt_number(columns = p.value, decimals = 6) %>%
  cols_align("center", everything())

gtsave(gt_logit, "output/tables/regresion_logistica_coeficientes.png")

# Separamos los datos en dos tablas para que los datos se lean mejor:
gt_logit_restantes <- coeficientes %>%
  filter(grepl("comuna[0-9]+:es_nocheSí", term)) %>%
  gt() %>%
  tab_header(title = "Interacciones: Comuna × Noche") %>%
  cols_label(
    term = "Término",
    estimate = "Estimación",
    std.error = "Error Std",
    statistic = "Estadístico Z",
    p.value = "p-valor"
  ) %>%
  fmt_number(columns = c(estimate, std.error, statistic), decimals = 4) %>%
  fmt_number(columns = p.value, decimals = 6) %>%
  cols_align("center", everything())

gtsave(gt_logit_restantes, "output/tables/regresion_logistica_coeficientes_restantes.png")

# Convertimos el ANOVA en un data frame:
anova_df <- as.data.frame(anova_modelo)
anova_df$termino <- rownames(anova_df)
anova_df <- anova_df[, c("termino", "Df", "Deviance", "Resid. Df", "Resid. Dev", "Pr(>Chi)")]

# Creamos una tabla para el ANOVA:
gt_anova <- gt(anova_df) %>%
  tab_header(title = "ANOVA del Modelo Logístico") %>%
  cols_label(
    termino = "Término",
    Df = "GL",
    Deviance = "Deviance",
    `Resid. Df` = "GL Residual",
    `Resid. Dev` = "Deviance Residual",
    `Pr(>Chi)` = "p-valor"
  ) %>%
  fmt_number(columns = c(Deviance, `Resid. Dev`), decimals = 2) %>%
  fmt_number(columns = `Pr(>Chi)`, decimals = 6) %>%
  cols_align(align = "center", columns = everything())

gtsave(gt_anova, "output/tables/regresion_logistica_anova.png")