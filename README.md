# Análisis del uso de Ecobici

Este proyecto analiza los patrones de uso del sistema de bicicletas públicas de Buenos Aires, con foco en las diferencias por género y cambio de uso entre el día y la noche.

El proyecto sigue un flujo secuencial y reproducible. Es importante descargar la carpeta completa del proyecto que incluye las subcarpetas de scripts.

Puede ejecutarse los scripts individualmente o el script master para ejecutar todos los scripts en orden.

Debido a que algunos csv tienen un peso muy elevado, debimos subirlos a Google Drive. Por ejemplo, en recorridos_2024.csv se encuentra el link a la carpeta pública donde se puede descargar el archivo en formato csv.

## Scripts

-   **master.R**: ejecuta todos los scripts en orden

-   **00_descarga_raw.R**: Descarga los datasets oficiales de usuarios y recorridos 2024 en data/raw.

-   **01_limpieza.R**: Procesa fechas, calcula duraciones y filtra recorridos inválidos.

-   **02_datos_auxiliares.R**: Obtiene la hora de salida y puesta del sol de Buenos Aires en 2024 mediante web scraping.

-   **03_estadisticas_descriptivas.R**: Genera las primeras estadísticas descriptivas y boxplots.

-   **04_estadisticas_descriptivas_sin_outliers.R**: Refina el análisis eliminando outliers extremos.

-   **05_dummy_noche.R**: Une los recorridos con los datos sobre puesta y salida del sol para clasificar los viajes entre diurnos y nocturnos.

-   **06_test_proporciones.R**: Realiza tests de proporciones (Género vs Noche).

-   **07_estaciones_barrio.R**: Procesa los datos geográficos de estaciones y barrios.

-   **08_recorridos_barrios.R**: Une la información espacial con los recorridos.

-   **09_test_barrios.R**: Evalúa la relación entre comuna y género.

-   **10_regresion_logistica.R**: Modelo estadístico para predecir el género según comuna y horario.

-   **11_grafico.R**: Genera mapa de calor con la caída en la proporción de uso durante la noche por comuna.

-   **12_grafico_2.R**: Visualización final de barras con la diferencia por comuna entre día y noche.
