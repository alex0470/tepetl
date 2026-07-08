# TEPETL 🌟

<div align="center">
  <img src="https://github.com/alex0470/tepetl/raw/main/assets/logo.png" alt="TEPETL Logo" width="200" height="200">
</div>

Interactive learning platform for the Nahuatl language with personalized feedback and intelligent exercise recommendations.

---

## 🌐 Available Languages | Idiomas Disponibles | Nēnēualtin Tlahtol

<div align="center">

| English | Español | Nāhuatl |
|---------|---------|---------|
| [📖 Read](#english) | [📖 Leer](https://github.com/alex0470/tepetl/blob/main/README_ES.md) | [📖 Xiquitta](#nāhuatl) |

</div>

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

TEPETL is an educational platform designed to facilitate interactive and personalized learning of the Nahuatl language. The application provides adaptive exercises, contextualized feedback, and an intelligent recommendation system powered by AI.

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
