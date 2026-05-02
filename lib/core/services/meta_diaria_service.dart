import 'package:shared_preferences/shared_preferences.dart';

class MetaDiariaService {
  static const _keyMeta = 'meta_diaria_minutos';
  static const _keyUltimoCambio = 'meta_ultima_cambio';
  static const _keyFechaHoy = 'estudio_fecha_hoy';
  static const _keySegundosHoy = 'estudio_segundos_hoy';

  static Future<int> obtenerMeta() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMeta) ?? 10;
  }

  static Future<bool> cambiarMeta(int nuevosMins) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await puedeCambiarMeta()) return false;
    await prefs.setInt(_keyMeta, nuevosMins);
    await prefs.setInt(
        _keyUltimoCambio, DateTime.now().millisecondsSinceEpoch);
    return true;
  }

  static Future<void> establecerMeta(int nuevosMins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMeta, nuevosMins);
    await prefs.setInt(
        _keyUltimoCambio, DateTime.now().millisecondsSinceEpoch);
  }

  /// `true` si nunca se ha establecido meta o han pasado ≥ 7 días.
  static Future<bool> puedeCambiarMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimoMs = prefs.getInt(_keyUltimoCambio);
    if (ultimoMs == null) return true;
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(ultimoMs));
    return diff.inDays >= 7;
  }

  static Future<int> diasParaCambiarMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimoMs = prefs.getInt(_keyUltimoCambio);
    if (ultimoMs == null) return 0;
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(ultimoMs));
    final restantes = 7 - diff.inDays;
    return restantes < 0 ? 0 : restantes;
  }

  static Future<int> obtenerMinutosHoy() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetearSiNuevoDia(prefs);
    final segundos = prefs.getInt(_keySegundosHoy) ?? 0;
    return (segundos / 60).floor();
  }

  /// Devuelve los segundos exactos estudiados hoy.
  static Future<int> obtenerSegundosHoy() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetearSiNuevoDia(prefs);
    return prefs.getInt(_keySegundosHoy) ?? 0;
  }

  static Future<void> registrarSesion(int segundos) async {
    if (segundos <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await _resetearSiNuevoDia(prefs);
    final acumulado = prefs.getInt(_keySegundosHoy) ?? 0;
    await prefs.setInt(_keySegundosHoy, acumulado + segundos);
  }

  static Future<void> _resetearSiNuevoDia(SharedPreferences prefs) async {
    final hoyStr = _fechaStr(DateTime.now());
    final guardado = prefs.getString(_keyFechaHoy) ?? '';
    if (guardado != hoyStr) {
      await prefs.setString(_keyFechaHoy, hoyStr);
      await prefs.setInt(_keySegundosHoy, 0);
    }
  }

  static String _fechaStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}