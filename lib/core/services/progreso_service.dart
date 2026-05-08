// lib/core/services/progreso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tepetl/core/services/perfil_aprendizaje_service.dart';

class ProgresoService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference _progresoRef(String cursoId) => _db
      .collection('users')
      .doc(_uid)
      .collection('progreso_cursos')
      .doc(cursoId);

  /// Guarda el estado parcial cuando el usuario pierde todas las vidas
  static Future<void> guardarEstadoParcial({
    required String cursoId,
    required String leccionId,
    String? moduloId,
    required int indiceActual,
    required int aciertosTotales,
    required int vidasPerdidas,
    required int pistasUsadas,
    required int maxRacha,
    required int rachaActual,
    required int erroresTraducir,
    required int erroresCompletar,
    required int erroresImagenes,
    required int tiempoSegundos,
    required List<String> ejerciciosIds,
  }) async {
    if (_uid == null) return;
    await _progresoRef(cursoId).set({
      'estadoParcial': {
        'leccionId': leccionId,
        'moduloId': moduloId,
        'indiceActual': indiceActual,
        'aciertosTotales': aciertosTotales,
        'vidasPerdidas': vidasPerdidas,
        'pistasUsadas': pistasUsadas,
        'maxRacha': maxRacha,
        'rachaActual': rachaActual,
        'erroresTraducir': erroresTraducir,
        'erroresCompletar': erroresCompletar,
        'erroresImagenes': erroresImagenes,
        'tiempoSegundos': tiempoSegundos,
        'ejerciciosIds': ejerciciosIds,
        'fechaGuardado': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  /// Limpia el estado parcial al completar o reiniciar la lección
  static Future<void> limpiarEstadoParcial(String cursoId) async {
    if (_uid == null) return;
    await _progresoRef(cursoId).update({'estadoParcial': FieldValue.delete()});
  }

  /// Lee el estado parcial guardado para una lección
  static Future<Map<String, dynamic>?> obtenerEstadoParcial(
      String cursoId, String leccionId) async {
    if (_uid == null) return null;
    final doc = await _progresoRef(cursoId).get();
    final data = doc.data() as Map<String, dynamic>?;
    final parcial = data?['estadoParcial'] as Map<String, dynamic>?;
    if (parcial == null) return null;
    if (parcial['leccionId'] != leccionId) return null;
    return parcial;
  }

  /// Guarda la lección completada y recalcula el porcentaje total del curso
  static Future<void> guardarLeccionCompletada({
    required String cursoId,
    required String leccionId,
    String? moduloId,
    required int totalLeccionesCurso,
    required int precision,
    required int xpGanada,
    required int aciertos,
    required int total,
    int tiempoSegundos = 0,
    int erroresTraducir = 0,
    int erroresCompletar = 0,
    int erroresImagenes = 0,
  }) async {
    if (_uid == null) return;
    final ref = _progresoRef(cursoId);
    final doc = await ref.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final completadas  = List<String>.from(data['leccionesCompletadas'] ?? []);
    final esNueva      = !completadas.contains(leccionId);
    if (esNueva) completadas.add(leccionId);

    final porcentaje = totalLeccionesCurso > 0
        ? completadas.length / totalLeccionesCurso
        : 0.0;

    // XP del día — resetear si es un día nuevo
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final fechaUltimaXP = data['fechaUltimaXP'] as String? ?? '';
    final xpHoyActual = fechaUltimaXP == hoy ? (data['xpHoy'] as int? ?? 0) : 0;

    // Guardar en progreso_cursos (xpHoy y porcentaje, NO xpTotal)
    await ref.set({
      'cursoId': cursoId,
      'moduloId': moduloId,
      'ultimaLeccion': leccionId,
      'ultimaActualizacion': FieldValue.serverTimestamp(),
      'leccionesCompletadas': completadas,
      'porcentajeTotal': porcentaje,
      'xpHoy': xpHoyActual + xpGanada,
      'fechaUltimaXP': hoy,
      'estadoParcial': FieldValue.delete(),
      'lecciones': {
        leccionId: {
          'completada': precision >= 70,
          'precision': precision,
          'aciertos': aciertos,
          'total': total,
          'fecha': FieldValue.serverTimestamp(),
        }
      },
    }, SetOptions(merge: true));

    // Historial de intentos — subcollección para consulta admin
    await ref.collection('historial').add({
      'leccionId': leccionId,
      'aciertos': aciertos,
      'total': total,
      'precision': precision,
      'completada': precision >= 70,
      'tiempoSegundos': tiempoSegundos,
      'erroresTraducir': erroresTraducir,
      'erroresCompletar': erroresCompletar,
      'erroresImagenes': erroresImagenes,
      'fecha': FieldValue.serverTimestamp(),
    });

    // XP total + contadores de progreso global en users/{uid}
    final userUpdate = <String, dynamic>{
      'xp': FieldValue.increment(xpGanada),
    };
    if (esNueva) {
      userUpdate['lecciones_totales'] = FieldValue.increment(1);
    }
    // Si el curso acaba de completarse por primera vez, suma cursos_completados
    final porcentajeAnterior = data['porcentajeTotal'] as double? ?? 0.0;
    final porcentajeNuevo    = totalLeccionesCurso > 0
        ? completadas.length / totalLeccionesCurso
        : 0.0;
    if (porcentajeAnterior < 1.0 && porcentajeNuevo >= 1.0) {
      userUpdate['cursos_completados'] = FieldValue.increment(1);
    }
    await _db.collection('users').doc(_uid).update(userUpdate);

    // Recompute learning profile async (fire-and-forget)
    PerfilAprendizajeService.actualizarPerfil(_uid!).ignore();
  }

  /// Lee el progreso completo de un curso
  static Future<Map<String, dynamic>> obtenerProgresoCurso(
      String cursoId) async {
    if (_uid == null) return {};
    final doc = await _progresoRef(cursoId).get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }
}