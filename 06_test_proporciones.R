if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, gt, webshot2)

# Establecemos un directorio reproducible:
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- dirname(rstudioapi::getSourceEditorContext()$path)
  setwd(dirname(script_path))
}

# Creamos los directorios necesarios en caso de que no existan:
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)

# Cargamos la base creada en el script 05:
recorridos_dia_noche <- read_csv("data/processed/recorridos_dia_noche.csv")

# Agrupamos los recorridos por género del usuario y por momento del día para 
# calcular la cantidad de observaciones de cada caso:
recorridos_test <- recorridos_dia_noche %>%
  group_by(genero, es_noche) %>%
  summarise(obs = n(), .groups = "drop") %>%
  # Colocamos a los géneros como columnas:
  pivot_wider(names_from = genero, values_from = obs) %>%
  select("FEMALE", "MALE")

# Realizamos el test de proporciones:
test <- prop.test(
  x = c(recorridos_test[[1,1]], recorridos_test[[2,1]]), n = c(sum(recorridos_test[1,]), sum(recorridos_test[2,])),
  alternative = "greater"
  )
print(test)

# Creamos un data frame con las estadísticas obtenidas a partir del test:
resultados_test <- data.frame(
  estadistico_X2 = round(test$statistic, 4),
  p_valor = format.pval(test$p.value, digits = 4),
  ic_95_inferior = round(test$conf.int[1], 4),
  ic_95_superior = round(test$conf.int[2], 4),
  decision = ifelse(test$p.value < 0.05, "Rechazo H0", "No rechazo H0")
)

# Creamos una tabla con los resultados y la guardamos:
gt_test <- gt(resultados_test) %>%
  tab_header(title = "Test de proporciones") %>%
  cols_align(align = "center", columns = everything())

gtsave(gt_test, "output/tables/test_proporciones.png")