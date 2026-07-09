import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np
import requests
import difflib

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"]
)

modelo = joblib.load("modelo_random_forest.pkl")
encoder = joblib.load("encoder.pkl")

GEMINI_API_KEY = os.environ["GEMINI_API_KEY"]

@app.get("/")
def inicio():
    return {"mensaje": "API del modelo funcionando"}

@app.post("/predecir")
def predecir(data: dict):

    valores = np.array([[
        data["aciertos_totales"],
        data["vidas_perdidas"],
        data["pistas_usadas"],
        data["tiempo_total_segundos"],
        data["max_racha_correctas"],    
        data["errores_traducir"],
        data["errores_completar"],
        data["errores_imagenes"]
    ]])

    pred = modelo.predict(valores)
    nivel = encoder.inverse_transform(pred)

    return {
        "nivel_predicho": nivel[0]
    }

@app.post("/evaluar-ejercicio")
def evaluar_ejercicio(data: dict):

    usuario = data["respuesta_usuario"]
    correcta = data["respuesta_correcta"]
    tipo = data["tipo"]

    if tipo == "traduccion":
        similitud = difflib.SequenceMatcher(
            None,
            usuario.lower(),
            correcta.lower()
        ).ratio()

        if similitud > 0.9:
            resultado = "correcto"
        elif similitud > 0.7:
            resultado = "casi correcto"
        else:
            resultado = "incorrecto"

    else:
        resultado = "correcto" if usuario.strip().lower() == correcta.strip().lower() else "incorrecto"
        similitud = 1.0 if resultado == "correcto" else 0.0

    if resultado == "correcto":
        feedback_base = f"¡Muy bien! '{correcta}' es correcto."
    elif resultado == "casi correcto":
        feedback_base = f"Casi correcto. La respuesta correcta es '{correcta}'."
    else:
        feedback_base = f"Incorrecto. La respuesta correcta es '{correcta}'."

    prompt = f"""
Eres un asistente educativo de náhuatl.

Da una retroalimentación MUY corta (máximo 1 línea).

Datos:
- Tipo: {tipo}
- Respuesta usuario: {usuario}
- Respuesta correcta: {correcta}
- Resultado: {resultado}

Reglas:
- Sé claro y amigable
- No expliques demasiado
- No uses JSON
- Solo una frase

Ejemplo:
"Recuerda que 'casa' se escribe con s, no con z."

Respuesta:
"""

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_API_KEY}"

    body = {
        "contents": [
            {
                "parts": [{"text": prompt}]
            }
        ]
    }

    feedback_ia = ""

    try:
        response = requests.post(url, json=body, timeout=2)

        if response.status_code == 200:
            feedback_ia = response.json()["candidates"][0]["content"]["parts"][0]["text"]
        else:
            feedback_ia = ""

    except:
        feedback_ia = ""

    return {
        "resultado": resultado,
        "similitud": similitud,
        "feedback_base": feedback_base,
        "feedback_ia": feedback_ia
    }

@app.post("/retroalimentacion")
def retroalimentacion(data: dict):

    ejercicios = data["ejercicios"]
    ejercicios_evaluados = []

    errores_traducir = 0
    errores_completar = 0
    errores_imagenes = 0
    aciertos = 0

    for e in ejercicios:

        usuario = e["respuesta_usuario"]
        correcta = e["respuesta_correcta"]
        tipo = e["tipo"]

        if tipo == "traduccion":
            similitud = difflib.SequenceMatcher(
                None,
                usuario.lower(),
                correcta.lower()
            ).ratio()

            if similitud > 0.9:
                resultado = "correcto"
            elif similitud > 0.7:
                resultado = "casi correcto"
            else:
                resultado = "incorrecto"
        else:
            resultado = "correcto" if usuario.strip().lower() == correcta.strip().lower() else "incorrecto"
        if resultado == "correcto":
            aciertos += 1
        else:
            if tipo == "traduccion":
                errores_traducir += 1
            elif tipo == "completar":
                errores_completar += 1
            elif tipo == "imagen":
                errores_imagenes += 1

        ejercicios_evaluados.append({
            "tipo": tipo,
            "respuesta_usuario": usuario,
            "respuesta_correcta": correcta,
            "resultado": resultado
        })

    prompt = f"""
Eres un asistente educativo, experto en la lengua materna nahuatl.

El sistema ya evaluó los ejercicios.

Tu tarea:
- Explicar errores claramente
- Dar retroalimentación útil
- Detectar patrones

Ejercicios:
{ejercicios_evaluados}

Responde SOLO en JSON válido:

{{
  "resultados": [
    {{
      "tipo": "",
      "resultado": "",
      "explicacion": ""
    }}
  ],
  "retroalimentacion_general": ""
}}
"""

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_API_KEY}"

    body = {
        "contents": [
            {
                "parts": [{"text": prompt}]
            }
        ]
    }

    response = requests.post(url, json=body)

    print("STATUS GEMINI:", response.status_code)
    print("RESPUESTA GEMINI: [redacted]")

    if response.status_code != 200:
        return {
            "error_gemini": response.text,
            "evaluacion_local": ejercicios_evaluados
        }

    try:
        texto = response.json()["candidates"][0]["content"]["parts"][0]["text"]
    except Exception:
        texto = "No se pudo generar retroalimentación en este momento."

    valores = np.array([[
        aciertos,
        data.get("vidas_perdidas", 0),
        data.get("pistas_usadas", 0),
        data.get("tiempo_total_segundos", 0),
        data.get("max_racha_correctas", 0),
        errores_traducir,
        errores_completar,
        errores_imagenes
    ]])

    pred = modelo.predict(valores)
    nivel = encoder.inverse_transform(pred)

    return {
        "evaluacion_local": ejercicios_evaluados,
        "retroalimentacion_ia": texto,
        "nivel_usuario": nivel[0]
    }