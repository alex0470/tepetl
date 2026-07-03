# TEPETL 🌟

Plataforma de aprendizaje interactivo de la lengua náhuatl, con retroalimentación personalizada y recomendaciones inteligentes de ejercicios.

> **Versión Web:** https://tepetl-a9d78.web.app/

---

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Características](#características)
- [Galería](#galería)
- [Instalación](#instalación)
- [Tecnologías](#tecnologías)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración](#configuración)
- [Contribuir](#contribuir)
- [Licencia](#licencia)

---

## 📖 Descripción

TEPETL es una plataforma educativa diseñada para facilitar el aprendizaje de la lengua náhuatl de manera interactiva y personalizada. La aplicación proporciona ejercicios adaptativos, retroalimentación inmediata y recomendaciones basadas en el desempeño del usuario.

### Objetivos

- ✅ Facilitar el aprendizaje del náhuatl a nivel básico
- ✅ Proporcionar retroalimentación contextualizada
- ✅ Adaptar los ejercicios según el progreso del usuario
- ✅ Crear una experiencia accesible y atractiva

---

## ✨ Características

- 🎯 **Ejercicios Adaptativos**: Los ejercicios se ajustan según tu nivel y desempeño
- 💬 **Retroalimentación Inmediata**: Obtén respuestas y sugerencias al instante
- 📊 **Seguimiento de Progreso**: Visualiza tu avance con gráficos y estadísticas
- 🌙 **Modo Oscuro**: Interfaz cómoda con temas claro y oscuro
- 📱 **Multiplataforma**: Disponible en Android, Web y Windows
- 🔒 **Autenticación Segura**: Acceso seguro con Firebase Authentication
- ☁️ **Sincronización en la Nube**: Tu progreso se sincroniza automáticamente

---

## 🖼️ Galería

### Pantalla Principal
![Pantalla Principal](https://github.com/alex0470/tepetl/blob/main/assets/galeria/pantallainicial.png)

### Ejercicios
![Ejercicios](https://via.placeholder.com/600x400?text=Ejercicios)

### Perfil y Ajustes
![Perfil y Ajustes](https://via.placeholder.com/600x400?text=Perfil+y+Ajustes)

### Modo Oscuro
![Modo Oscuro](https://via.placeholder.com/600x400?text=Modo+Oscuro)

---

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Android Studio o Xcode (para desarrollo móvil)
- Cuenta de Firebase

### Pasos de Instalación

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

## 🛠️ Tecnologías

- **Frontend**: Flutter / Dart
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
- **Hosting**: Firebase Hosting
- **Lenguajes**: Dart (95.4%), C++ (2.3%), CMake (1.7%), HTML (0.3%)

---

## 📁 Estructura del Proyecto

```
tepetl/
├── lib/
│   ├── app.dart                 # Aplicación principal
│   ├── firebase_options.dart    # Configuración de Firebase
│   ├── core/
│   │   ├── screens/             # Pantallas principales
│   │   │   ├── usuario/         # Pantallas de usuario
│   │   │   └── inicio/          # Pantalla de inicio
│   │   ├── widgets/             # Widgets reutilizables
│   │   └── theme/               # Configuración de temas
│   └── ...
├── android/                     # Código específico para Android
├── windows/                     # Código específico para Windows
├── firebase.json                # Configuración de Firebase
├── analysis_options.yaml        # Opciones de análisis Dart
└── pubspec.yaml                 # Dependencias del proyecto
```

---

## ⚙️ Configuración

### Firebase Setup

La aplicación está preconfigurada con Firebase. Los detalles de configuración están en:

- `firebase_options.dart` - Configuración automática
- `firebase.json` - Configuración del hosting y plataformas
- Project ID: `tepetl-a9d78`

### CORS

La configuración CORS está definida en `cors.json` para permitir solicitudes GET desde cualquier origen.

### Análisis de Código

Se utiliza `flutter_lints` para mantener la calidad del código. Ejecuta:

```bash
flutter analyze
```

---

## 🤝 Contribuir

¿Quieres contribuir? ¡Estamos abiertos a colaboraciones!

1. Fork el repositorio
2. Crea una rama para tu característica (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

---

## 📧 Contacto

Para preguntas, sugerencias o reportar problemas, contacta a través de:
- 📊 Issues: [GitHub Issues](https://github.com/alex0470/tepetl/issues)
- 💌 Email: alex0470@gmail.com

---

**Hecho con ❤️ para la preservación y enseñanza de la lengua náhuatl**
