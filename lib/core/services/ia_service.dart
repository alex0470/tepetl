import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IAService {
  static const String _baseUrl = 'apiurl'; // Reemplaza con la URL de tu API

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  /// Evaluación global al terminar un examen/lección. Devuelve XP, precisión y mensaje.
  static Future<Map<String, dynamic>> evaluarExamen({
    required int aciertosTotales,
    required int totalEjercicios,
    required int vidasPerdidas,
    required int pistasUsadas,
    required int maxRacha,
    required int erroresTraducir,
    required int erroresCompletar,
    required int erroresImagenes,
    required int tiempoSegundos,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predecir'),
        headers: _headers,
        body: jsonEncode({
          'aciertos_totales': aciertosTotales,
          'vidas_perdidas': vidasPerdidas,
          'pistas_usadas': pistasUsadas,
          'max_racha_correctas': maxRacha,
          'errores_traducir': erroresTraducir,
          'errores_completar': erroresCompletar,
          'errores_imagenes': erroresImagenes,
          'tiempo_total_segundos': tiempoSegundos,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('IAService.evaluarExamen error: $e');
    }
    // Fallback — sin precision/xp para que el llamador use cálculo local
    return {'mensaje_ai': 'Buen esfuerzo. Sigue practicando.'};
  }

  /// Retroalimentación inmediata por ejercicio individual (/evaluar-ejercicio).
  /// La API devuelve: { "feedback_ia": "...", "feedback_base": "..." }
  /// Este método normaliza y devuelve: { "retroalimentacion": "..." }
  static Future<Map<String, dynamic>> evaluarEjercicio({
    required String tipo,
    required String contenido,
    required String respuestaUsuario,
    required String respuestaCorrecta,
    required bool esCorrecta,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/evaluar-ejercicio'),
        headers: _headers,
        body: jsonEncode({
          'tipo': _mapTipoParaAPI(tipo),
          'respuesta_usuario': respuestaUsuario,
          'respuesta_correcta': respuestaCorrecta,
          'es_correcto': esCorrecta,
        }),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        // La API devuelve feedback_ia (de Gemini) o feedback_base (local)
        final texto = _textoNoVacio(body['feedback_ia']) ??
            _textoNoVacio(body['feedback_base']) ??
            '';
        return {'retroalimentacion': texto};
      }
    } catch (e) {
      debugPrint('IAService.evaluarEjercicio error: $e');
    }
    return {};
  }

  /// Retroalimentación detallada al finalizar la lección (/retroalimentacion).
  /// La API espera: { "ejercicios": [{tipo, respuesta_usuario, respuesta_correcta}] }
  /// La API devuelve: { "retroalimentacion_ia": "\<JSON string de Gemini\>", "evaluacion_local": [...] }
  static Future<Map<String, dynamic>> obtenerRetroalimentacion({
    required int precision,
    required int aciertos,
    required int total,
    required int tiempoSegundos,
    required List<Map<String, dynamic>> errores,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/retroalimentacion'),
        headers: _headers,
        body: jsonEncode({
          'ejercicios': errores.map((e) => {
                'tipo': _mapTipoParaAPI(e['tipo'] as String? ?? ''),
                'respuesta_usuario': e['respuesta_usuario'] ?? '',
                'respuesta_correcta': e['respuesta_correcta'] ?? '',
              }).toList(),
          'tiempo_total_segundos': tiempoSegundos,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return _normalizarRetroalimentacion(body);
      }
    } catch (e) {
      debugPrint('IAService.obtenerRetroalimentacion error: $e');
    }
    return {};
  }

  // ── Helpers internos ────────────────────────────────────────────────────────

  /// Mapea los tipos de ejercicio de Flutter al formato que espera la API Python.
  static String _mapTipoParaAPI(String tipo) {
    switch (tipo) {
      case 'leer_escribir':
        return 'traduccion';
      case 'completar_frase':
        return 'completar';
      case 'seleccionar_imagen':
        return 'imagen';
      default:
        return tipo;
    }
  }

  static String? _textoNoVacio(dynamic valor) {
    final s = valor?.toString().trim();
    return (s != null && s.isNotEmpty) ? s : null;
  }

  /// Convierte la respuesta cruda de /retroalimentacion al formato interno de Flutter.
  /// La API devuelve `retroalimentacion_ia` como string JSON de Gemini con la forma:
  ///   { "resultados": [{tipo, resultado, explicacion}], "retroalimentacion_general": "..." }
  static Map<String, dynamic> _normalizarRetroalimentacion(
      Map<String, dynamic> body) {
    final retroStr = body['retroalimentacion_ia'] as String? ?? '';
    String resumen = '';
    List<Map<String, dynamic>> erroresNormalizados = [];

    try {
      // Gemini puede rodear el JSON con ```json ... ```
      final limpio = retroStr
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'```\s*$', multiLine: true), '')
          .trim();

      final parsed = jsonDecode(limpio) as Map<String, dynamic>;
      resumen = parsed['retroalimentacion_general'] as String? ?? '';

      final resultados = parsed['resultados'] as List<dynamic>? ?? [];
      erroresNormalizados = resultados.asMap().entries.map((entry) {
        final r = entry.value as Map<String, dynamic>;
        return {
          'indice': entry.key,
          'nota': r['explicacion'] as String? ?? '',
          'tipo_error': r['tipo'] as String? ?? '',
        };
      }).toList();
    } catch (_) {
      // Si Gemini no devolvió JSON válido, usar el string directamente
      resumen = _textoNoVacio(retroStr) ?? '';
    }

    return {
      'resumen': resumen,
      'errores': erroresNormalizados,
    };
  }
}
