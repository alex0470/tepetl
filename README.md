# TEPETL 🌟

<div align="center">
  <img src="https://github.com/alex0470/tepetl/raw/main/assets/logo.png" alt="TEPETL Logo" width="200" height="200">
</div>

Interactive learning platform for the Nahuatl language with personalized feedback and intelligent exercise recommendations.

**📚 Available in:** [English](#english) | [Español](#español) | [Nāhuatl](#nāhuatl)

> **Live Demo:** https://tepetl-a9d78.web.app/

---

## English

### 📋 Table of Contents

- [Description](#description)
- [Features](#features)
- [Gallery](#gallery)
- [Installation](#installation)
- [Technologies](#technologies)
- [Project Structure](#project-structure)
- [Datasets](#datasets)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

---

### 📖 Description

TEPETL is an educational platform designed to facilitate interactive and personalized learning of the Nahuatl language. The application provides adaptive exercises, contextualized feedback, and an intelligent system that recommends exercises based on user progress and performance.

The platform combines modern technology with cultural preservation, offering an engaging experience for language learners of all levels.

#### Objectives

- ✅ Facilitate learning of Nahuatl at basic level
- ✅ Provide contextualized feedback
- ✅ Adapt exercises according to user progress
- ✅ Create an accessible and attractive experience

---

### ✨ Features

- 🎯 **Adaptive Exercises**: Exercises adjust to your level and performance
- 💬 **Immediate Feedback**: Get answers and suggestions instantly
- 📊 **Progress Tracking**: Visualize your progress with graphs and statistics
- 🌙 **Dark Mode**: Comfortable interface with light and dark themes
- 📱 **Cross-Platform**: Available on Android, Web, and Windows
- 🔒 **Secure Authentication**: Safe access with Firebase Authentication
- ☁️ **Cloud Synchronization**: Your progress syncs automatically

---

### 🖼️ Gallery

#### Main Screen
![Main Screen](https://github.com/alex0470/tepetl/blob/main/assets/galeria/pantallainicial.png)

#### Exercises
![Exercises](https://github.com/alex0470/tepetl/blob/main/assets/galeria/ejercicios.png)

#### Profile and Settings
![Profile and Settings](https://github.com/alex0470/tepetl/blob/main/assets/galeria/perfil_ajustes.png)

#### Dark Mode
![Dark Mode](https://github.com/alex0470/tepetl/blob/main/assets/galeria/modo_oscuro.png)

---

### 🚀 Installation

#### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK
- Android Studio or Xcode (for mobile development)
- Firebase account

#### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/alex0470/tepetl.git
cd tepetl

# 2. Install dependencies
flutter pub get

# 3. Run the application (web)
flutter run -d chrome

# 4. Run the application (Android)
flutter run -d android
```

---

### 🛠️ Technologies

- **Frontend**: Flutter / Dart
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
- **Hosting**: Firebase Hosting
- **AI**: FastAPI + Google Gemini + Random Forest Classifier
- **Languages**: Dart (91.8%), Jupyter Notebook (3.2%), C++ (2.2%), CMake (1.7%), Python (0.5%), HTML (0.3%)

---

### 📁 Project Structure

```
tepetl/
├── lib/
│   ├── main.dart                      # Entry point
│   ├── app.dart                       # Root widget (MaterialApp, theme)
│   └── core/
│       ├── models/                    # Data models (course, exercise, review, article)
│       ├── screens/
│       │   ├── autenticacion/         # Login, register, password recovery, level selection
│       │   ├── inicio/                # Landing page, splash and onboarding
│       │   ├── principales/           # User tabs: home, courses, dictionary, culture, AI summary
│       │   ├── principalesadmin/      # Admin panel (users, courses, modules, lessons, AI)
│       │   ├── plantillas_ejercicios/ # Exercise types: translate, complete, images, level exam
│       │   ├── usuario/               # Profile, settings, badges, levels, streaks
│       │   └── errores/               # Error summary and review after finishing a lesson
│       ├── services/                  # Firestore/Storage/Auth access and business logic
│       ├── theme/                     # Colors and light/dark theme
│       └── widgets/                   # Reusable components
├── backend/                           # AI API (FastAPI) that predicts level and provides feedback
│   ├── api_nivel.py
│   ├── entrenamiento1.ipynb           # Model training notebook
│   ├── datasets/                      # Word, exercise and exam data
│   ├── modelo_random_forest.pkl       # Trained model (not versioned)
│   └── encoder.pkl                    # Label encoder (not versioned)
├── assets/                            # Images, fonts, audio and seed data
├── android/ ios/ macos/ windows/ linux/ web/   # Native projects per platform
├── firebase.json / firestore.rules    # Firebase configuration and security rules
└── pubspec.yaml                       # Project dependencies
```

---

### 📊 Datasets

#### Overview

The project includes three main datasets used to train and validate the AI model:

#### 1. **Nahuatl Words Dataset** (`palabras.json` / CSV)
- **Content**: Fundamental Nahuatl vocabulary with translations and categories
- **Structure**:
  - `id`: Unique identifier
  - `palabra_nahuatl`: Word in Nahuatl
  - `traduccion_espanol`: Spanish translation
  - `categoria`: Category (nouns, verbs, adjectives, etc.)
  - `nivel`: Difficulty level (Basic, Basic+, Intermediate)
  - `audio`: Path to audio file (optional)
  - `imagen`: Path to associated image (optional)

- **Usage**: 
  - Population of translation exercises
  - Platform dictionary base
  - User response validation

#### 2. **Exercises Dataset** (`ejercicios.json` / CSV)
- **Content**: Collection of exercises of different types
- **Structure**:
  - `id`: Unique identifier
  - `tipo`: Exercise type (translation, complete, image)
  - `pregunta`: Question text
  - `respuesta_correcta`: Expected answer
  - `opciones`: Answer options (for multiple choice)
  - `nivel`: Difficulty level
  - `modulo`: Module it belongs to
  - `retroalimentacion_base`: Predefined feedback

- **Exercise Types**:
  - **Translation**: User translates words/phrases from Spanish to Nahuatl
  - **Complete**: User fills in blank spaces
  - **Image**: User identifies words from images

- **Usage**:
  - Dynamic exercise generation
  - User performance evaluation
  - Difficulty adaptation

#### 3. **Classification Exams Dataset** (`dataset_examenes.csv`)
- **Content**: 50,000 exam result records to train the level prediction model
- **Structure**:
  - `aciertos_totales`: Total correct answers (0-10)
  - `vidas_perdidas`: Lives lost in exam (0-10)
  - `pistas_usadas`: Number of hints used (0-10)
  - `tiempo_total_segundos`: Total exam time in seconds (20-623)
  - `max_racha_correctas`: Maximum streak of consecutive correct answers (0-10)
  - `errores_traducir`: Translation exercise errors
  - `errores_completar`: Completion exercise errors
  - `errores_imagenes`: Image exercise errors
  - `nivel_asignado`: **Label** - Predicted level (Basic, Basic+, Intermediate)

- **Dataset Statistics**:
  - Total records: 50,000
  - Level distribution:
    - Basic: 35,759 (71.5%)
    - Basic+: 10,630 (21.3%)
    - Intermediate: 3,611 (7.2%)
  - No duplicates
  - Model accuracy: **87.44%**

- **Metrics by Class**:
  - Basic: Precision=0.90, Recall=0.97, F1=0.93
  - Basic+: Precision=0.77, Recall=0.78, F1=0.77
  - Intermediate: Precision=0.93, Recall=0.21, F1=0.34

- **Usage**:
  - Random Forest model training
  - User level prediction based on performance
  - Cross-validation and performance metrics

### Dataset Location

```
backend/
├── datasets/
│   ├── palabras.csv (or .json)           # Vocabulary
│   ├── ejercicios.csv (or .json)         # Exercises
│   └── dataset_examenes.csv              # Training dataset (50K records)
├── entrenamiento1.ipynb                  # Analysis and training notebook
├── modelo_random_forest.pkl              # Serialized model (not versioned)
└── encoder.pkl                           # LabelEncoder (not versioned)
```

### Level Prediction Model

**Algorithm**: Random Forest Classifier
- **Estimators**: 50 trees
- **Max Depth**: 5
- **Random State**: 42

**Most Important Features**:
1. `aciertos_totales` - More weight in prediction
2. `errores_traducir` - Specific translation errors
3. `tiempo_total_segundos` - Response speed
4. `vidas_perdidas` - Accumulated penalties
5. `pistas_usadas` - Help dependency

---

### ⚙️ Configuration

#### Firebase Setup

The application is preconfigured with Firebase. Configuration details are in:

- `firebase_options.dart` - Automatic configuration
- `firebase.json` - Hosting and platform configuration
- Project ID: `tepetl-a9d78`

#### Backend API Setup

The AI API runs with FastAPI:

```bash
# Install dependencies
pip install -r backend/requirements.txt

# Set environment variable
export GEMINI_API_KEY="your_gemini_key_here"

# Run server
cd backend
uvicorn api_nivel:app --reload --host 0.0.0.0 --port 8000
```

**Main Endpoints**:
- `POST /predecir` - Predicts user level
- `POST /evaluar-ejercicio` - Evaluates individual exercise
- `POST /retroalimentacion` - Generates general feedback with AI

#### CORS

CORS configuration is defined in `cors.json` to allow GET requests from any origin.

#### Code Analysis

`flutter_lints` is used to maintain code quality. Run:

```bash
flutter analyze
```

---

### 🤝 Contributing

Want to contribute? We're open to collaborations!

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

### 📝 License

This project is licensed under the MIT License. See `LICENSE` for more details.

---

### 📧 Contact

For questions, suggestions, or to report issues, contact:
- 📊 Issues: [GitHub Issues](https://github.com/alex0470/tepetl/issues)
- 💌 Email: silvestrealexanderolverarocha@gmail.com

---

**Made with ❤️ for the preservation and teaching of the Nahuatl language**

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

TEPETL es una plataforma educativa diseñada para facilitar el aprendizaje de la lengua náhuatl de manera interactiva y personalizada. La aplicación proporciona ejercicios adaptativos, retroalimentación contextualizada, y un sistema inteligente que recomienda ejercicios según el progreso y desempeño del usuario.

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

---

## Nāhuatl

### 📋 Tlahcuilolmahtecpantli

- [Tlahcuilolmachtilizti](#tlahcuilolmachtilizti)
- [Nextlaoaliztli](#nextlaoaliztli)
- [Galearia](#galearia)
- [Tlacenilizti](#tlacenilizti)
- [Tequitl in Nextlaoali](#tequitl-in-nextlaoali)
- [Namictiliztli in Tlamantli](#namictiliztli-in-tlamantli)
- [Machtiloni](#machtiloni)
- [Tlacencaliztli](#tlacencaliztli)
- [Nextlaoaliztli](#nextlaoaliztli-1)
- [Licencia](#licencia-nahuatl)

---

### 📖 Tlahcuilolmachtilizti

TEPETL huel mochiuh in nextlaoaliztli, in tlalachiuhtilizti in nauatl tetlactlaoaliztli. In altepetl nican mochiuh in nextlaoaloni in huey in machtilizti, in tleica oniuh in huan in tleica nextlaoaliztli.

In altepetl nican ihtac in neixin in techtequitl huan in nahuatl machtilizti.

#### Aquimachtilizti

- ✅ Nextlaoaliztli in nauatl tetlactlaoaliztli
- ✅ Tleica nextlaoaliztli in oniuh
- ✅ Nextlaoaloni in oniuh in machtilizti
- ✅ Nextlaoaliztli in huel neltoca

---

### ✨ Nextlaoaliztli

- 🎯 **Nextlaoaloni in Oniuh**: In nextlaoaloni mochiuhtiuh in tech huan in oniuh
- 💬 **Nahuatilli Huiquipanin**: Xiquitta in tleica oniuh huan in cocentlahui
- 📊 **Nextlaoaliztli in Oniuh**: Xiquitta in oniuh in nahui huan in huey
- 🌙 **Tonacayotl Yohualli**: Neltoca in ixquichtin tlahuiloni
- 📱 **Miquechtin Atlaltin**: Nonotzaloni in Android, Web, huan Windows
- 🔒 **Tlamictiliztli in Cuztlaoaliztli**: Tlamictiliztli in Firebase Authentication
- ☁️ **Nextlaoaliztli in Ilhuicatl**: In oniuh mochihuazquia in ompa ilhuicatl

---

### 🖼️ Galearia

#### Tlahuilonalli in Imixpan
![Tlahuilonalli in Imixpan](https://github.com/alex0470/tepetl/blob/main/assets/galeria/pantallainicial.png)

#### Nextlaoaloni
![Nextlaoaloni](https://github.com/alex0470/tepetl/blob/main/assets/galeria/ejercicios.png)

#### Toca huan Tlacencaliztli
![Toca huan Tlacencaliztli](https://github.com/alex0470/tepetl/blob/main/assets/galeria/perfil_ajustes.png)

#### Tonacayotl Yohualli
![Tonacayotl Yohualli](https://github.com/alex0470/tepetl/blob/main/assets/galeria/modo_oscuro.png)

---

### 🚀 Tlacenilizti

#### Azo Altepetl in Tlamictiliztli

- Flutter SDK (3.0 tlahuelmachtiloni o huo occequintin)
- Dart SDK
- Android Studio o Xcode (in nextlaoaliztli in noquichtli)
- Tlamictiliztli in Firebase

#### Tlacenilizti in Huazqueh

```bash
# 1. Xicueponi in nextlaoaliztli
git clone https://github.com/alex0470/tepetl.git
cd tepetl

# 2. Xitlamictiloni in occequintin tlamahqueh
flutter pub get

# 3. Xiquixtiloni in nextlaoaliztli (web)
flutter run -d chrome

# 4. Xiquixtiloni in nextlaoaliztli (Android)
flutter run -d android
```

---

### 🛠️ Tequitl in Nextlaoali

- **Imixpan**: Flutter / Dart
- **Tonacatl**: Firebase
  - Tlamictiliztli
  - Firestore Database
  - Cloud Storage
- **Tlahuilonalli**: Firebase Hosting
- **Nextlaoaliztli in Netecinematl**: FastAPI + Google Gemini + Random Forest Classifier
- **Tetlactlaoaliztli**: Dart (91.8%), Jupyter Notebook (3.2%), C++ (2.2%), CMake (1.7%), Python (0.5%), HTML (0.3%)

---

### 📁 Namictiliztli in Tlamantli

```
tepetl/
├── lib/
│   ├── main.dart                      # Tlamantli in Imixpan
│   ├── app.dart                       # Icpac tlamantli (MaterialApp, tonacayotl)
│   └── core/
│       ├── models/                    # Tlahtlaloni (nextlaoaliztli, nextlaoaloni, ahuactlamictiliztli, atlatl)
│       ├── screens/
│       │   ├── autenticacion/         # Cueponiztli, tlacenilizti, nextlaoaliztli occehuiliztli, nahuatililiztli
│       │   ├── inicio/                # Imixpan, ihtetiuh huan nextlaoaliztli
│       │   ├── principales/           # Imixpan tlamantli: imixpan, nextlaoaliztli, tetlamictiloni, nauatl, huey nextlaoaliztli
│       │   ├── principalesadmin/      # Tlamancaliztli in hueliloni (toca, nextlaoaliztli, tlamantli, machtiloni, netecinematl)
│       │   ├── plantillas_ejercicios/ # Nextlaoaloni: nahuatililiztli, tetlamictiloni, ixtlamictiloni, hueliloni nahuatililiztli
│       │   ├── usuario/               # Toca, tlacencaliztli, nextlaoaliztli, hueliloni, coquiniuh
│       │   └── errores/               # Ahuactlamictiliztli huan nextlaoaliztli in occe machtiloni
│       ├── services/                  # Tlamictiliztli Firestore/Storage/Authentication huan tequitl in nextlaoali
│       ├── theme/                     # Tlahuiloni huan tonacayotl
│       └── widgets/                   # Tlamantli in nextlaoaliztli
├── backend/                           # Netecinematl API (FastAPI) in nextlaoaliztli huan nextlaoaliztli
│   ├── api_nivel.py
│   ├── entrenamiento1.ipynb           # Tlacuicuiloni in nextlaoaliztli
│   ├── datasets/                      # Tlahtlaloni: tetlactlaoaliztli, nextlaoaloni huan nahuatililiztli
│   ├── modelo_random_forest.pkl       # Nextlaoaliztli in cencah machtiloni (zan no)
│   └── encoder.pkl                    # Tlamictiliztli in totoctin (zan no)
├── assets/                            # Ixtlamictiloni, tlahuiloni, tlachizaliztli huan occehuiliztli tlahtlaloni
├── android/ ios/ macos/ windows/ linux/ web/   # Tequitl niquichtli in achi tlamantli
├── firebase.json / firestore.rules    # Tlacencaliztli huan tlamictiliztli in Firebase
└── pubspec.yaml                       # Tlamahqueh in nextlaoaliztli
```

---

### 📊 Machtiloni

#### Huey Tlahtlaloni

In nextlaoaliztli nican ihtac nahui in huel nextlaoaliztli in tlamahqueh in nextlaoaliztli:

#### 1. **Machtiloni in Tetlactlaoaliztli Nauatl** (`palabras.json` / CSV)
- **Tleica**: Tetlactlaoaliztli in nauatl huan in ompa espanoltin huan tlamantli
- **Namictiliztli**:
  - `id`: Tonacayotl ozomoztli
  - `palabra_nahuatl`: Tetlactlaoaliztli in nauatl
  - `traduccion_espanol`: Tetlactlaoaliztli in espanoltin
  - `categoria`: Tlamantli (nopiltin, nextlaoaliztli, occehuiliztli, etc.)
  - `nivel`: Hueliloni in machtilizti (Yohualli, Yohualli+, Tonacayotl)
  - `audio`: Tocayotl in tlachizaliztli (zan no)
  - `imagen`: Tocayotl in ixtlamictiloni (zan no)

- **Nextlaoaliztli**: 
  - Tlamantli in nahuatililiztli nextlaoaloni
  - Tonacatl in tetlamictiloni
  - Nextlaoaliztli in tlamantli

#### 2. **Machtiloni in Nextlaoaloni** (`ejercicios.json` / CSV)
- **Tleica**: Cocentlahui in nextlaoaloni in huel tlamantli
- **Namictiliztli**:
  - `id`: Tonacayotl ozomoztli
  - `tipo`: Tlamantli in nextlaoaloni (nahuatililiztli, tetlamictiloni, ixtlamictiloni)
  - `pregunta`: Tetlactlaoaliztli in huehuetzaloni
  - `respuesta_correcta`: Nahuatilli in neltoca
  - `opciones`: Occequintin nahuatilli (in occequintin nextlaoaloni)
  - `nivel`: Hueliloni in machtilizti
  - `modulo`: Tlamantli in machtilizti
  - `retroalimentacion_base`: Nextlaoaliztli in huel mocenquizque

- **Tlamantli in Nextlaoaloni**:
  - **Nahuatililiztli**: Tlamantli in nahuatililiztli in espanoltin huan nauatl
  - **Tetlamictiloni**: Tlamantli in tetlamictiloni in tonacayotl
  - **Ixtlamictiloni**: Tlamantli in ixtlamictiloni in tonacayotl

- **Nextlaoaliztli**:
  - Tlamantli in nextlaoaloni
  - Nextlaoaliztli in tlamantli
  - Nextlaoaliztli in hueliloni

#### 3. **Machtiloni in Nahuatililiztli Tlahcuilolmachtilizti** (`dataset_examenes.csv`)
- **Tleica**: 50,000 tlamantli in nahuatililiztli in nextlaoaliztli
- **Namictiliztli**:
  - `aciertos_totales`: Huey cocentlahui in neltoca (0-10)
  - `vidas_perdidas`: Vidas in occe (0-10)
  - `pistas_usadas`: Nextlaoaliztli in tozque (0-10)
  - `tiempo_total_segundos`: Huey tecpatl in nahuatililiztli (20-623)
  - `max_racha_correctas`: Cocentlahui in neltoca in tlahuelmachtiloni (0-10)
  - `errores_traducir`: Ahuactlamictiliztli in nahuatililiztli
  - `errores_completar`: Ahuactlamictiliztli in tetlamictiloni
  - `errores_imagenes`: Ahuactlamictiliztli in ixtlamictiloni
  - `nivel_asignado`: **Tlahcuilolmachtilizti** - Hueliloni (Yohualli, Yohualli+, Tonacayotl)

- **Tlamantli in Machtiloni**:
  - Huey tlamantli: 50,000
  - Hueliloni in namictiliztli:
    - Yohualli: 35,759 (71.5%)
    - Yohualli+: 10,630 (21.3%)
    - Tonacayotl: 3,611 (7.2%)
  - Zan no occequintin
  - Nextlaoaliztli in nextlaoaliztli: **87.44%**

- **Nextlaoaliztli in Tlamantli**:
  - Yohualli: Precision=0.90, Recall=0.97, F1=0.93
  - Yohualli+: Precision=0.77, Recall=0.78, F1=0.77
  - Tonacayotl: Precision=0.93, Recall=0.21, F1=0.34

- **Nextlaoaliztli**:
  - Nextlaoaliztli in nextlaoaliztli Random Forest
  - Nextlaoaliztli in hueliloni
  - Nextlaoaliztli huan huey tlamantli

### Tocayotl in Machtiloni

```
backend/
├── datasets/
│   ├── palabras.csv (o .json)           # Tetlactlaoaliztli
│   ├── ejercicios.csv (o .json)         # Nextlaoaloni
│   └── dataset_examenes.csv             # Machtiloni in nextlaoaliztli (50K)
├── entrenamiento1.ipynb                 # Notebook in nextlaoaliztli huan nextlaoaliztli
├── modelo_random_forest.pkl             # Nextlaoaliztli in ompa (zan no)
└── encoder.pkl                          # Tlamictiliztli LabelEncoder (zan no)
```

### Nextlaoaliztli in Hueliloni Nextlaoaliztli

**Tequitl**: Random Forest Classifier
- **Tlamantli**: 50 cuahuitl
- **Huey Hueliloni**: 5
- **Ozomoztli**: 42

**Huel Nextlaoaliztli in Tlamantli**:
1. `aciertos_totales` - Huey occehuiliztli in nextlaoaliztli
2. `errores_traducir` - Ahuactlamictiliztli in nahuatililiztli
3. `tiempo_total_segundos` - Huey tlamantli in nahuatililiztli
4. `vidas_perdidas` - Ahuactlamictiliztli in occehuiliztli
5. `pistas_usadas` - Nextlaoaliztli in tozque

---

### ⚙️ Tlacencaliztli

#### Tlacencaliztli in Firebase

In nextlaoaliztli nican ozomoztli in Firebase. In tlacencaliztli nican:

- `firebase_options.dart` - Ozomoztli in tlacencaliztli
- `firebase.json` - Tlacencaliztli in tlahuilonalli huan tlamantli
- Project ID: `tepetl-a9d78`

#### Tlacencaliztli in Backend API

In netecinematl API in tequiti in FastAPI:

```bash
# Tlacenilizti in occequintin tlamahqueh
pip install -r backend/requirements.txt

# Tlamictiliztli in tlahuiloni
export GEMINI_API_KEY="in ompa gemini occehuiliztli aqui"

# Tequiti in tonacatl
cd backend
uvicorn api_nivel:app --reload --host 0.0.0.0 --port 8000
```

**Huel API nextlaoaliztli**:
- `POST /predecir` - Nextlaoaliztli in hueliloni
- `POST /evaluar-ejercicio` - Nextlaoaliztli in nextlaoaloni
- `POST /retroalimentacion` - Nextlaoaliztli in huey nextlaoaliztli netecinematl

#### CORS

In tlacencaliztli CORS nican nextlaoaliztli in `cors.json` in tlahuilonalli in achi ompa.

#### Nextlaoaliztli in Tequitl

In `flutter_lints` in nextlaoaliztli in calidad in tequitl. Xiquixtiloni:

```bash
flutter analyze
```

---

### 🤝 Nextlaoaliztli

Azo quixcomania? ¡In nextlaoaliztli in huelmachtiloni!

1. Fork in nextlaoaliztli
2. Tlamantli in quixcomania (`git checkout -b feature/AmazingFeature`)
3. Commit in tlamahqueh (`git commit -m 'Add some AmazingFeature'`)
4. Push in tlamantli (`git push origin feature/AmazingFeature`)
5. Xiquixtiloni in Pull Request

---

### 📝 Licencia

In nextlaoaliztli nican ihtac in Licencia MIT. Xiquitta `LICENSE` in huel tlahtlaloni.

---

### 📧 Nextlaoaliztli

In huehuetzaloni, nextlaoaliztli o nahuatililiztli in occequintin tlamantli:
- 📊 Ahuactlamictiliztli: [GitHub Ahuactlamictiliztli](https://github.com/alex0470/tepetl/issues)
- 💌 Email: silvestrealexanderolverarocha@gmail.com

---

**Mochiuh in nextlaoaliztli ❤️ in preservacion huan nextlaoaliztli in nauatl tetlactlaoaliztli**
