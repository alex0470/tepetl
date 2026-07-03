# Backend de IA

Servicio FastAPI que evalúa ejercicios, predice el nivel del usuario y genera retroalimentación con Google Gemini AI (usado por `lib/core/services/ia_service.dart`).

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Configuración](#configuración)
- [Datasets](#datasets)
- [Estructura del Modelo](#estructura-del-modelo)
- [Endpoints](#endpoints)
- [Uso](#uso)

---

## 📖 Descripción

El backend proporciona tres funcionalidades principales:

1. **Evaluación de Ejercicios** - Valida respuestas con similitud fuzzy para traducciones
2. **Predicción de Nivel** - Utiliza Random Forest para clasificar el nivel del usuario (Básico, Básico+, Intermedio)
3. **Retroalimentación con IA** - Genera feedback personalizado usando Google Gemini

---

## ⚙️ Configuración

### Requisitos Previos

- Python 3.8+
- FastAPI
- joblib (para cargar modelos)
- requests
- numpy

### Instalación

```bash
# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install fastapi uvicorn joblib numpy requests python-multipart
```

### Variables de Entorno

Requiere la variable de entorno `GEMINI_API_KEY` (nunca la escribas directamente en `api_nivel.py`):

```bash
export GEMINI_API_KEY="tu_clave_de_gemini_aqui"
```

### Ejecutar el Servidor

```bash
# Desarrollo
uvicorn api_nivel:app --reload --host 0.0.0.0 --port 8000

# Producción
uvicorn api_nivel:app --host 0.0.0.0 --port 8000 --workers 4
```

El servidor estará disponible en `http://localhost:8000`

### Archivos Requeridos

También necesita los archivos entrenados generados por `entrenamiento1.ipynb`:

- `modelo_random_forest.pkl` - Modelo Random Forest entrenado
- `encoder.pkl` - LabelEncoder para convertir predicciones a niveles

Estos archivos **no se versionan** por su tamaño (~50-100MB).

---

## 📊 Datasets

### 1. Dataset de Palabras (`palabras.csv` o `palabras.json`)

Vocabulario fundamental con palabras en náhuatl y sus traducciones.

**Estructura**:
```csv
id,palabra_nahuatl,traduccion_espanol,categoria,nivel,audio,imagen
1,casa,casa,sustantivo,Basico,,
2,tonacatl,carne,sustantivo,Basico,,
3,atl,agua,sustantivo,Basico,,
```

**Columnas**:
- `id`: Identificador único
- `palabra_nahuatl`: Palabra en náhuatl
- `traduccion_espanol`: Traducción al español
- `categoria`: Categoría gramatical
- `nivel`: Nivel de dificultad
- `audio`: Ruta a archivo de audio (opcional)
- `imagen`: Ruta a imagen (opcional)

### 2. Dataset de Ejercicios (`ejercicios.csv` o `ejercicios.json`)

Colección de ejercicios de diferentes tipos para los usuarios.

**Estructura**:
```csv
id,tipo,pregunta,respuesta_correcta,opciones,nivel,modulo,retroalimentacion_base
1,traduccion,¿Cómo se dice "casa" en náhuatl?,calli,"calli,tepetl,tonacatl",Basico,Modulo1,Correcto!
2,completar,__ significa agua,atl,atl,Basico,Modulo1,Bien hecho
3,imagen,Identifica la imagen,gato,gato,Basico,Modulo1,Excelente respuesta
```

**Columnas**:
- `id`: Identificador único
- `tipo`: Tipo de ejercicio (traduccion, completar, imagen)
- `pregunta`: Texto de la pregunta
- `respuesta_correcta`: Respuesta esperada
- `opciones`: Opciones separadas por coma (si aplica)
- `nivel`: Nivel de dificultad
- `modulo`: Módulo al que pertenece
- `retroalimentacion_base`: Retroalimentación predefinida

**Tipos de Ejercicios**:
- **Traducción**: Usuario traduce del español al náhuatl
- **Completar**: Usuario completa espacios en blanco
- **Imagen**: Usuario identifica palabras desde imágenes

### 3. Dataset de Exámenes (`dataset_examenes.csv`)

**50,000 registros** de resultados de exámenes para entrenar el modelo de predicción de nivel.

**Estructura**:
```csv
aciertos_totales,vidas_perdidas,pistas_usadas,tiempo_total_segundos,max_racha_correctas,errores_traducir,errores_completar,errores_imagenes,nivel_asignado
8,7,3,91,3,4,1,2,Basico+
7,4,3,135,2,1,1,2,Basico
6,5,3,126,5,2,2,1,Basico+
```

**Columnas de Características**:
- `aciertos_totales`: Respuestas correctas (0-10)
- `vidas_perdidas`: Vidas perdidas (0-10)
- `pistas_usadas`: Pistas utilizadas (0-10)
- `tiempo_total_segundos`: Duración en segundos (20-623)
- `max_racha_correctas`: Racha máxima de aciertos (0-10)
- `errores_traducir`: Errores en traducción
- `errores_completar`: Errores en completar
- `errores_imagenes`: Errores en imagen

**Etiqueta**:
- `nivel_asignado`: Nivel predicho (Básico, Básico+, Intermedio)

**Estadísticas**:
- Total: 50,000 registros
- Distribución:
  - Básico: 35,759 (71.5%)
  - Básico+: 10,630 (21.3%)
  - Intermedio: 3,611 (7.2%)
- Sin duplicados
- Accuracy del modelo: **87.44%**

---

## 🧠 Estructura del Modelo

### Algoritmo: Random Forest Classifier

```python
RandomForestClassifier(
    n_estimators=50,      # 50 árboles de decisión
    max_depth=5,          # Profundidad máxima de 5 niveles
    random_state=42       # Reproducibilidad
)
```

### Rendimiento

| Métrica | Básico | Básico+ | Intermedio | Promedio |
|---------|--------|---------|-----------|----------|
| Precision | 0.90 | 0.77 | 0.93 | 0.87 |
| Recall | 0.97 | 0.78 | 0.21 | 0.65 |
| F1-Score | 0.93 | 0.77 | 0.34 | 0.68 |

**Accuracy General**: 87.44%

### Importancia de Características

(De mayor a menor impacto en la predicción):
1. `aciertos_totales` - Número total de respuestas correctas
2. `errores_traducir` - Errores específicos en traducción
3. `tiempo_total_segundos` - Tiempo invertido en el examen
4. `vidas_perdidas` - Penalizaciones acumuladas
5. `pistas_usadas` - Dependencia de ayudas

---

## 🔌 Endpoints

### 1. `GET /`

**Descripción**: Verifica que la API está funcionando

**Respuesta**:
```json
{
  "mensaje": "API del modelo funcionando"
}
```

---

### 2. `POST /predecir`

**Descripción**: Predice el nivel del usuario basado en su desempeño

**Request Body**:
```json
{
  "aciertos_totales": 7,
  "vidas_perdidas": 2,
  "pistas_usadas": 1,
  "tiempo_total_segundos": 180,
  "max_racha_correctas": 5,
  "errores_traducir": 1,
  "errores_completar": 0,
  "errores_imagenes": 1
}
```

**Response**:
```json
{
  "nivel_predicho": "Básico+"
}
```

---

### 3. `POST /evaluar-ejercicio`

**Descripción**: Evalúa una respuesta individual y genera feedback contextualizado

**Request Body**:
```json
{
  "respuesta_usuario": "tonacatl",
  "respuesta_correcta": "tonacatl",
  "tipo": "traduccion"
}
```

**Response**:
```json
{
  "resultado": "correcto",
  "similitud": 1.0,
  "feedback_base": "¡Muy bien! 'tonacatl' es correcto.",
  "feedback_ia": "¡Excelente! Has acertado la palabra náhuatl para carne."
}
```

**Tipos de Resultado**:
- `correcto`: Respuesta exacta (o similitud > 0.9 para traducciones)
- `casi correcto`: Similitud entre 0.7 y 0.9 (solo traducciones)
- `incorrecto`: Respuesta incorrecta (similitud < 0.7)

---

### 4. `POST /retroalimentacion`

**Descripción**: Genera retroalimentación general después de completar una serie de ejercicios

**Request Body**:
```json
{
  "ejercicios": [
    {
      "respuesta_usuario": "tonacatl",
      "respuesta_correcta": "tonacatl",
      "tipo": "traduccion"
    },
    {
      "respuesta_usuario": "atl",
      "respuesta_correcta": "atl",
      "tipo": "completar"
    }
  ],
  "vidas_perdidas": 1,
  "pistas_usadas": 0,
  "tiempo_total_segundos": 240,
  "max_racha_correctas": 3
}
```

**Response**:
```json
{
  "evaluacion_local": [
    {
      "tipo": "traduccion",
      "respuesta_usuario": "tonacatl",
      "respuesta_correcta": "tonacatl",
      "resultado": "correcto"
    }
  ],
  "retroalimentacion_ia": "Tu desempeño ha sido excelente. Dominas bien las palabras básicas...",
  "nivel_usuario": "Básico+"
}
```

---

## 🚀 Uso

### Ejemplo con Python

```python
import requests

BASE_URL = "http://localhost:8000"

# 1. Predecir nivel
response = requests.post(
    f"{BASE_URL}/predecir",
    json={
        "aciertos_totales": 8,
        "vidas_perdidas": 2,
        "pistas_usadas": 1,
        "tiempo_total_segundos": 150,
        "max_racha_correctas": 4,
        "errores_traducir": 1,
        "errores_completar": 1,
        "errores_imagenes": 0
    }
)
print(response.json())  # {'nivel_predicho': 'Básico+'}

# 2. Evaluar ejercicio
response = requests.post(
    f"{BASE_URL}/evaluar-ejercicio",
    json={
        "respuesta_usuario": "atl",
        "respuesta_correcta": "atl",
        "tipo": "completar"
    }
)
print(response.json())
```

### Ejemplo con cURL

```bash
# Verificar que la API está activa
curl http://localhost:8000/

# Predecir nivel
curl -X POST http://localhost:8000/predecir \
  -H "Content-Type: application/json" \
  -d '{
    "aciertos_totales": 7,
    "vidas_perdidas": 3,
    "pistas_usadas": 2,
    "tiempo_total_segundos": 200,
    "max_racha_correctas": 3,
    "errores_traducir": 2,
    "errores_completar": 1,
    "errores_imagenes": 0
  }'
```

---

## 📁 Estructura de Archivos

```
backend/
├── api_nivel.py                         # API principal (FastAPI)
├── entrenamiento1.ipynb                 # Notebook de entrenamiento
├── modelo_random_forest.pkl             # Modelo (no versionado)
├── encoder.pkl                          # Encoder (no versionado)
├── datasets/
│   ├── palabras.csv (o .json)           # Vocabulario
│   ├── ejercicios.csv (o .json)         # Ejercicios
│   └── dataset_examenes.csv             # Dataset de entrenamiento (50K)
├── requirements.txt                     # Dependencias Python
└── README.md                            # Este archivo
```

---

## 🔒 Notas de Seguridad

- Nunca guardes `GEMINI_API_KEY` en el código
- En producción, usa variables de entorno o gestores de secretos
- Implementa rate limiting para los endpoints
- Valida siempre las entradas del usuario

---

## 📝 Licencia

Este proyecto está bajo la Licencia MIT.
