# Project 201

## General

El proyecto predice la probabilidad de ganar el siguiente partido de Valorant **según el mapa** basado en:
- **Patrones de tiempo** → Aprende de las rachas de victorias/derrotas según las tendencias de rendimiento
- **Caracteristicas** → Evalua y predice según el mapa, agente, kills, muertes, asistencias y predice la probabilidad de ganar y el KDA esperado.
- **Hybrid combination** →  Se promedian ambas probabilidades de los modelos para una recomendación más realista

## Funcionamiento

### Requisitos
- Python 3.9+ (recomendado).
- Conocimiento básico de la linea de comandos/terminal.
- Archivo de información
## Instalando en Windows
1. Descarga e instala python desde la [microsoft store](https://apps.microsoft.com/detail/9PNRBTZXMB4Z?hl=neutral&gl=CL&ocid=pdpshare)
2. Abre CMD y escribe:
```bash
pip install pandas numpy scikit-learn xgboost torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```
3. Después de que termine, pon los 3 archivos dentro de una carpeta y anda desde CMD a la carpeta del proyecto:
```bash
cd %folder%
```
## Installing on Linux/Mac
1. Descarga e instala python desde la [página de macos](https://www.python.org/downloads/macos/)
2. Abre CMD y escribe:
```bash
pip install pandas numpy scikit-learn xgboost torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
```
Nota: si esto no funciona, entra a un entorno virtual (virtual environment):
```bash
python -m venv .venv
source .venv/bin/activate
```
3.  Después de que termine, pon los 3 archivos dentro de una carpeta y anda a la carpeta del proyecto:
```bash
cd %folder%
```
## Para exportar tus partidas a un archivo CSV
1. Visita [tracker.gg/valorant](https://tracker.gg/valorant) y busca tu perfil. 
2. Baja y carga el maximo de partidas que gustes (recomendado: al menos 100)
3. Descarga la página dando click derecho en cualquier espacio en blanco de la página
4. Abre el archivo .htm, copia todo con Ctrl+A y pegalo en un archivo .txt, poniendo tu ID de riot como nombre del archivo (ejemplo: astato#86.txt)
5. Pon el archivo tuID.txt dentro de la carpeta con el proyecto entero
6. Ejecuta launch.py en CMD/terminal:
```bash
python launch.py
```
#### Solamente en Linux/Mac
Nota: si esto no funciona, entra a un entorno virtual (virtual environment):
```bash
python -m venv .venv
source .venv/bin/activate
```
7. Selecciona la opción 2, pon el mismo ID como el archivo tuID.txt de antes.
8. Ahora tienes el archivo .csv con el mismo nombre ID de antes, resultado: ID.csv
   
## Usando en Windows:
1. Abre CMD, ve a la locación de tu carpeta con el proyecto-
2. Ejecuta launch.py:
```bash
python launch.py
```
3. Escoje la opción 1 y escribe el mismo ID del archivo .csv anterior (tu id de riot)
4. Escoje el mapa solo poniendo el nombre!
## Usando en Linux/Mac:
1. Abre CMD, ve a la locación de tu carpeta con el proyecto-
2. Ejecuta launch.py:
```bash
python launch.py
```
Nota: si esto no funciona, entra al entorno virtual anterior (virtual environment):
```bash
python -m venv .venv
source .venv/bin/activate
```
3. Escoje la opción 1 y escribe el mismo ID del archivo .csv anterior (tu id de riot)
4. Escoje el mapa solo poniendo el nombre!

## Output 
Predicciones finales para el siguiente partido (todos los agentes jugados en ese mapa):
Map: Ascent
  - Jett | Win Probability 0.72 | Expected KDA 2.10
  - Reyna | Win Probability 0.65 | Expected KDA 1.95
  - Killjoy | Win Probability 0.60 | Expected KDA 1.80
## Considerations
1. El modelo predecirá los partidos de acuerdo a los partidos cargados desde el archivo .csv, se recomienda actualizar el archivo .csv con cada partido que juegues para obtener mejores resultados. Por ahora debes sobrescribir manualmente el archivo .csv tú mismo, debes escribir una nueva línea en el archivo .csv con el formato que verás.
2. El modelo NO ES 100% perfecto, porque es una versión alfa, hablando de mi propia investigación supongo que tiene un 65%-80% de predicciones correctas.
3. Si el modelo arroja todas derrotas, recomiendo probar un agente nuevo que no hayas jugado en ese mapa.
### Proyecciones futuras conocidas
1. Interfaz de usuario
2. Aprendizaje del partido actual
3. Actualización automática del archivo CSV
4. Uso de la GPU
## Saludos
Agradecimientos especiales a Revit y Magiñho por ser sujetos de prueba.

