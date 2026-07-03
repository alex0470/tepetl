# Backend de IA

Servicio FastAPI que evalúa ejercicios, predice el nivel del usuario y genera retroalimentación con Gemini (usado por `lib/core/services/ia_service.dart`).

## Configuración

Requiere la variable de entorno `GEMINI_API_KEY` (nunca la escribas directamente en `api_nivel.py`):

```bash
export GEMINI_API_KEY="tu_clave_aqui"
uvicorn api_nivel:app --reload
```

También necesita los archivos entrenados `modelo_random_forest.pkl` y `encoder.pkl` (generados por `entrenamiento1.ipynb`) en este mismo directorio; no se versionan por su tamaño.
