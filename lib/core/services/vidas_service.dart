import 'package:shared_preferences/shared_preferences.dart';

class VidasService {
  static const int maxCorazones = 10;
  static const int minutosRecarga = 1;

  static Future<int> obtenerCorazones() async {
    final prefs = await SharedPreferences.getInstance();
    int corazones = prefs.getInt('corazones') ?? maxCorazones;
    String? ultimaVezStr = prefs.getString('ultima_vez_corazon');

    if (corazones < maxCorazones && ultimaVezStr != null) {
      DateTime ultimaVez = DateTime.parse(ultimaVezStr);
      DateTime ahora = DateTime.now();
      Duration diferencia = ahora.difference(ultimaVez);

      int corazonesRecuperados = diferencia.inMinutes ~/ minutosRecarga;

      if (corazonesRecuperados > 0) {
        corazones += corazonesRecuperados;
        
        if (corazones >= maxCorazones) {
          corazones = maxCorazones;
          await prefs.remove('ultima_vez_corazon');
        } else {
          DateTime nuevaFecha = ultimaVez.add(Duration(minutes: corazonesRecuperados * minutosRecarga));
          await prefs.setString('ultima_vez_corazon', nuevaFecha.toIso8601String());
        }
        await prefs.setInt('corazones', corazones);
      }
    }
    return corazones;
  }

  static Future<int> gastarCorazon() async {
    final prefs = await SharedPreferences.getInstance();
    int corazonesActuales = await obtenerCorazones();

    if (corazonesActuales > 0) {
      corazonesActuales--;
      await prefs.setInt('corazones', corazonesActuales);

      if (corazonesActuales == maxCorazones - 1) {
        await prefs.setString('ultima_vez_corazon', DateTime.now().toIso8601String());
      }
    }
    return corazonesActuales;
  }

  static Future<Duration> tiempoParaSiguienteCorazon() async {
    final prefs = await SharedPreferences.getInstance();
    
    int corazones = await obtenerCorazones(); 
    
    if (corazones >= maxCorazones) return Duration.zero;

    String? ultimaVezStr = prefs.getString('ultima_vez_corazon');
    if (ultimaVezStr == null) return Duration.zero;

    DateTime ultimaVez = DateTime.parse(ultimaVezStr);
    DateTime proximaRecarga = ultimaVez.add(const Duration(minutes: minutosRecarga));
    DateTime ahora = DateTime.now();

    Duration diff = proximaRecarga.difference(ahora);
    
    return diff.isNegative ? Duration.zero : diff;
  }
}