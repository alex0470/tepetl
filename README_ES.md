# TEPETL 🌟

<div align="center">
  <img src="https://github.com/alex0470/tepetl/raw/main/assets/logo.png" alt="TEPETL Logo" width="200" height="200">
</div>

Plataforma interactiva de aprendizaje para el idioma náhuatl con retroalimentación personalizada y recomendaciones inteligentes de ejercicios.

---

## 🌐 Available Languages | Idiomas Disponibles | Nēnēualtin Tlahtol

<div align="center">

| English | Español | Nāhuatl |
|---------|---------|---------|
| [📖 Read](https://github.com/alex0470/tepetl/blob/main/README.md) | [📖 Leer](https://github.com/alex0470/tepetl/blob/main/README_ES.md) | [📖 Xiquitta](https://github.com/alex0470/tepetl/blob/main/README_NA.md) |

</div>

> **Live Demo:** https://tepetl-a9d78.web.app/

---

## Español

### 📋 Tabla de Contenidos

- [Descripción](#descripción-1)
- [Características](#características-1)
- [Galería](#galería-1)
- [Instalación](#instalación-1)
- [Tecnologías](#tecnologías-1)
- [Estructura del Proyecto](#estructura-del-proyecto-1)
- [Datasets](#datasets-1)
- [Configuración](#configuración-1)
- [Contribuir](#contribuir-1)
- [Licencia](#licencia-1)

---

### 📖 Descripción

TEPETL es una plataforma educativa diseñada para facilitar el aprendizaje de la lengua náhuatl de manera interactiva y personalizada. La aplicación proporciona ejercicios adaptativos, retroalimentación contextualizada y un sistema de recomendación inteligente impulsado por IA.

La plataforma combina tecnología moderna con preservación cultural, ofreciendo una experiencia atractiva para aprendices de todos los niveles.

#### Objetivos

- ✅ Facilitar el aprendizaje del náhuatl a nivel básico
- ✅ Proporcionar retroalimentación contextualizada
- ✅ Adaptar los ejercicios según el progreso del usuario
- ✅ Crear una experiencia accesible y atractiva

---

### ✨ Características

- 🎯 **Ejercicios Adaptativos**: Los ejercicios se ajustan según tu nivel y desempeño
- 💬 **Retroalimentación Inmediata**: Obtén respuestas y sugerencias al instante
- 📊 **Seguimiento de Progreso**: Visualiza tu avance con gráficos y estadísticas
- 🌙 **Modo Oscuro**: Interfaz cómoda con temas claro y oscuro
- 📱 **Multiplataforma**: Disponible en Android, Web y Windows
- 🔒 **Autenticación Segura**: Acceso seguro con Firebase Authentication
- ☁️ **Sincronización en la Nube**: Tu progreso se sincroniza automáticamente

---

### 🖼️ Galería

#### Pantalla Principal
![Pantalla Principal](https://github.com/alex0470/tepetl/blob/main/assets/galeria/pantallainicial.png)

#### Ejercicios
![Ejercicios](https://github.com/alex0470/tepetl/blob/main/assets/galeria/ejercicios.png)

#### Perfil y Ajustes
![Perfil y Ajustes](https://github.com/alex0470/tepetl/blob/main/assets/galeria/perfil_ajustes.png)

#### Modo Oscuro
![Modo Oscuro](https://github.com/alex0470/tepetl/blob/main/assets/galeria/modo_oscuro.png)

---

### 🚀 Instalación

#### Requisitos Previos

- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Android Studio o Xcode (para desarrollo móvil)
- Cuenta de Firebase

#### Pasos de Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/alex0470/tepetl.git
cd tepetl

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar la aplicación (web)
flutter run -d chrome

# 4. Ejecutar la aplicación (Android)
flutter run -d android
```

---

### 🛠️ Tecnologías

- **Frontend**: Flutter / Dart
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
- **Hosting**: Firebase Hosting
- **IA**: FastAPI + Google Gemini + Random Forest Classifier
- **Lenguajes**: Dart (91.8%), Jupyter Notebook (3.2%), C++ (2.2%), CMake (1.7%), Python (0.5%), HTML (0.3%)

---

### 📁 Estructura del Proyecto

```
tepetl/
├── lib/
│   ├── main.dart                      # Punto de entrada
│   ├── app.dart                       # Widget raíz (MaterialApp, tema)
│   └── core/
│       ├── models/                    # Modelos de datos (curso, ejercicio, revisión, artículo)
│       ├── screens/
│       │   ├── autenticacion/         # Login, registro, recuperar contraseña, selección de nivel
│       │   ├── inicio/                # Landing page, splash y onboarding
│       │   ├── principales/           # Tabs del usuario: inicio, cursos, diccionario, cultura, resumen IA
│       │   ├── principalesadmin/      # Panel de administración (usuarios, cursos, módulos, lecciones, IA)
│       │   ├── plantillas_ejercicios/ # Tipos de ejercicio: traducir, completar, imágenes, examen de nivel
│       │   ├── usuario/               # Perfil, ajustes, insignias, niveles, racha
│       │   └── errores/               # Resumen y revisión de errores al terminar una lección
│       ├── services/                  # Acceso a Firestore/Storage/Auth y lógica de negocio
│       ├── theme/                     # Colores y tema claro/oscuro
│       └── widgets/                   # Componentes reutilizables
├── backend/                           # API de IA (FastAPI) que predice nivel y da retroalimentación
│   ├── api_nivel.py
│   ├── entrenamiento1.ipynb           # Notebook de entrenamiento del modelo
│   ├── datasets/                      # Datos de palabras, ejercicios y exámenes
│   ├── modelo_random_forest.pkl       # Modelo entrenado (no versionado)
│   └── encoder.pkl                    # Encoder de labels (no versionado)
├── assets/                            # Imágenes, fuentes, audio y datos semilla
├── android/ ios/ macos/ windows/ linux/ web/   # Proyectos nativos por plataforma
├── firebase.json / firestore.rules    # Configuración y reglas de seguridad de Firebase
└── pubspec.yaml                       # Dependencias del proyecto
```

---

### 📊 Datasets

#### Descripción General

El proyecto incluye tres datasets principales utilizados para entrenar y validar el modelo de IA:

#### 1. **Dataset de Palabras Náhuatl** (`palabras.json` / CSV)
- **Contenido**: Vocabulario fundamental en náhuatl con traducciones y categorías
- **Estructura**:
  - `id`: Identificador único
  - `palabra_nahuatl`: Palabra en náhuatl
  - `traduccion_espanol`: Traducción al español
  - `categoria`: Categoría (sustantivos, verbos, adjetivos, etc.)
  - `nivel`: Nivel de dificultad (Básico, Básico+, Intermedio)
  - `audio`: Ruta al archivo de audio (opcional)
  - `imagen`: Ruta a la imagen asociada (opcional)

- **Uso**: 
  - Población de ejercicios de traducción
  - Base del diccionario de la plataforma
  - Validación de respuestas de usuarios

#### 2. **Dataset de Ejercicios** (`ejercicios.json` / CSV)
- **Contenido**: Colección de ejercicios de diferentes tipos
- **Estructura**:
  - `id`: Identificador único
  - `tipo`: Tipo de ejercicio (traduccion, completar, imagen)
  - `pregunta`: Texto de la pregunta
  - `respuesta_correcta`: Respuesta esperada
  - `opciones`: Opciones de respuesta (para ejercicios de opción múltiple)
  - `nivel`: Nivel de dificultad
  - `modulo`: Módulo al que pertenece
  - `retroalimentacion_base`: Retroalimentación predefinida

- **Tipos de Ejercicios**:
  - **Traducción**: Usuario traduce palabras/frases del español al náhuatl
  - **Completar**: Usuario completa espacios en blanco
  - **Imagen**: Usuario identifica palabras a partir de imágenes

- **Uso**:
  - Generación dinámica de ejercicios
  - Evaluación del desempeño del usuario
  - Adaptación de dificultad

#### 3. **Dataset de Exámenes de Clasificación** (`dataset_examenes.csv`)
- **Contenido**: 50,000 registros de resultados de exámenes para entrenar el modelo de predicción de nivel
- **Estructura**:
  - `aciertos_totales`: Número total de respuestas correctas (0-10)
  - `vidas_perdidas`: Vidas perdidas en el examen (0-10)
  - `pistas_usadas`: Número de pistas utilizadas (0-10)
  - `tiempo_total_segundos`: Tiempo total de examen en segundos (20-623)
  - `max_racha_correctas`: Racha máxima de respuestas correctas consecutivas (0-10)
  - `errores_traducir`: Errores en ejercicios de traducción
  - `errores_completar`: Errores en ejercicios de completar
  - `errores_imagenes`: Errores en ejercicios de imagen
  - `nivel_asignado`: **Etiqueta** - Nivel predicho (Básico, Básico+, Intermedio)

- **Estadísticas del Dataset**:
  - Total de registros: 50,000
  - Distribución de niveles:
    - Básico: 35,759 (71.5%)
    - Básico+: 10,630 (21.3%)
    - Intermedio: 3,611 (7.2%)
  - Sin duplicados
  - Accuracy del modelo: **87.44%**

- **Métricas por Clase**:
  - Básico: Precision=0.90, Recall=0.97, F1=0.93
  - Básico+: Precision=0.77, Recall=0.78, F1=0.77
  - Intermedio: Precision=0.93, Recall=0.21, F1=0.34

- **Uso**:
  - Entrenamiento del modelo Random Forest
  - Predicción del nivel de usuario basada en su desempeño
  - Validación cruzada y métricas de rendimiento

### Ubicación de Datasets

```
backend/
├── datasets/
│   ├── palabras.csv (o .json)           # Vocabulario
│   ├── ejercicios.csv (o .json)         # Ejercicios
│   └── dataset_examenes.csv             # Dataset de entrenamiento (50K registros)
├── entrenamiento1.ipynb                 # Notebook de análisis y entrenamiento
├── modelo_random_forest.pkl             # Modelo serializado (no versionado)
└── encoder.pkl                          # Encoder LabelEncoder (no versionado)
```

### Modelo de Predicción de Nivel

**Algoritmo**: Random Forest Classifier
- **Estimadores**: 50 árboles
- **Profundidad máxima**: 5
- **Random State**: 42

**Características más Importantes**:
1. `aciertos_totales` - Más peso en la predicción
2. `errores_traducir` - Errores específicos de traducción
3. `tiempo_total_segundos` - Velocidad de respuesta
4. `vidas_perdidas` - Penalizaciones acumuladas
5. `pistas_usadas` - Dependencia de ayuda

---

### ⚙️ Configuración

#### Configuración de Firebase

La aplicación está preconfigurada con Firebase. Los detalles de configuración están en:

- `firebase_options.dart` - Configuración automática
- `firebase.json` - Configuración del hosting y plataformas
- Project ID: `tepetl-a9d78`

#### Configuración de Backend API

La API de IA se ejecuta con FastAPI:

```bash
# Instalar dependencias
pip install -r backend/requirements.txt

# Configurar variable de entorno
export GEMINI_API_KEY="tu_clave_de_gemini_aqui"

# Ejecutar servidor
cd backend
uvicorn api_nivel:app --reload --host 0.0.0.0 --port 8000
```

**Endpoints principales**:
- `POST /predecir` - Predice el nivel del usuario
- `POST /evaluar-ejercicio` - Evalúa un ejercicio individual
- `POST /retroalimentacion` - Genera retroalimentación general con IA

#### CORS

La configuración CORS está definida en `cors.json` para permitir solicitudes GET desde cualquier origen.

#### Análisis de Código

Se utiliza `flutter_lints` para mantener la calidad del código. Ejecuta:

```bash
flutter analyze
```

---

### 🤝 Contribuir

¿Quieres contribuir? ¡Estamos abiertos a colaboraciones!

1. Fork el repositorio
2. Crea una rama para tu característica (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

### 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

---

### 📧 Contacto

Para preguntas, sugerencias o reportar problemas, contacta a través de:
- 📊 Issues: [GitHub Issues](https://github.com/alex0470/tepetl/issues)
- 💌 Email: silvestrealexanderolverarocha@gmail.com

---

**Hecho con ❤️ para la preservación y enseñanza de la lengua náhuatl**
