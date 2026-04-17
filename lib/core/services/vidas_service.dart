import 'package:shared_preferences/shared_preferences.dart';

class VidasService {
  static const int maxCorazones = 10;
  static const int minutosRecarga = 1;

  // 1. Obtener los corazones actuales (calculando si ya pasó el tiempo)
  static Future<int> obtenerCorazones() async {
    final prefs = await SharedPreferences.getInstance();
    int corazones = prefs.getInt('corazones') ?? maxCorazones;
    String? ultimaVezStr = prefs.getString('ultima_vez_corazon');

    // Si le faltan corazones, calculamos cuánto tiempo ha pasado
    if (corazones < maxCorazones && ultimaVezStr != null) {
      DateTime ultimaVez = DateTime.parse(ultimaVezStr);
      DateTime ahora = DateTime.now();
      Duration diferencia = ahora.difference(ultimaVez);

      // Cuántos corazones enteros se han recuperado en este tiempo
      int corazonesRecuperados = diferencia.inMinutes ~/ minutosRecarga;

      if (corazonesRecuperados > 0) {
        corazones += corazonesRecuperados;
        
        if (corazones >= maxCorazones) {
          corazones = maxCorazones;
          await prefs.remove('ultima_vez_corazon'); // Ya está lleno
        } else {
          // Si no se llenó, adelantamos el reloj para la próxima recarga
          DateTime nuevaFecha = ultimaVez.add(Duration(minutes: corazonesRecuperados * minutosRecarga));
          await prefs.setString('ultima_vez_corazon', nuevaFecha.toIso8601String());
        }
        await prefs.setInt('corazones', corazones);
      }
    }
    return corazones;
  }

  // 2. Restar un corazón cuando se equivocan
  static Future<int> gastarCorazon() async {
    final prefs = await SharedPreferences.getInstance();
    int corazonesActuales = await obtenerCorazones();

    if (corazonesActuales > 0) {
      corazonesActuales--;
      await prefs.setInt('corazones', corazonesActuales);

      // Si es el primer corazón que pierde, empezamos a contar el tiempo
      if (corazonesActuales == maxCorazones - 1) {
        await prefs.setString('ultima_vez_corazon', DateTime.now().toIso8601String());
      }
    }
    return corazonesActuales;
  }

  // 3. Calcular cuánto tiempo falta para el siguiente corazón
  static Future<Duration> tiempoParaSiguienteCorazon() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Al llamar a obtenerCorazones, de paso actualiza si ya pasó el tiempo
    int corazones = await obtenerCorazones(); 
    
    // Si ya estamos al máximo, no hay tiempo de espera
    if (corazones >= maxCorazones) return Duration.zero;

    String? ultimaVezStr = prefs.getString('ultima_vez_corazon');
    if (ultimaVezStr == null) return Duration.zero;

    DateTime ultimaVez = DateTime.parse(ultimaVezStr);
    DateTime proximaRecarga = ultimaVez.add(const Duration(minutes: minutosRecarga));
    DateTime ahora = DateTime.now();

    // Calculamos la diferencia
    Duration diff = proximaRecarga.difference(ahora);
    
    // Si por alguna razón da negativo (ya se pasó el tiempo), devolvemos cero
    return diff.isNegative ? Duration.zero : diff;
  }
}