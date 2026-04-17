import 'dart:convert';
import 'package:http/http.dart' as http;

class IAService {
  // ⚠️ Cambia esta URL cada vez que reinicies ngrok
  static const String _baseUrl = 'https://bebe-quixotic-stalkily.ngrok-free.dev';

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
        headers: {
          'Content-Type': 'application/json',
          // ngrok a veces requiere este header para evitar la página de advertencia
          'ngrok-skip-browser-warning': 'true',
        },
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
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error llamando a IA: $e');
    }

    // Fallback si falla la conexión
    return {
      'mensaje_ai': 'Buen esfuerzo. Sigue practicando.',
      'precision': 0,
      'xp': 0,
    };
  }
}