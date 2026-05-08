import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tepetl/core/models/modelo_ejercicio.dart';

/// Computes and stores a learning profile per user.
/// Path: users/{uid}/perfil/aprendizaje
class PerfilAprendizajeService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference _perfilRef(String uid) =>
      _db.collection('users').doc(uid).collection('perfil').doc('aprendizaje');

  // ── Compute & persist ──────────────────────────────────────────────────────

  /// Full recompute from historial. Call fire-and-forget after saving a lesson.
  static Future<void> actualizarPerfil(String uid) async {
    try {
      final cursosSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('progreso_cursos')
          .get();

      if (cursosSnap.docs.isEmpty) return;

      int totalAciertos = 0;
      int totalErrores = 0;
      int totalTiempo = 0;
      int countTiempo = 0;
      int erroresTraducir = 0;
      int erroresCompletar = 0;
      int erroresImagenes = 0;

      final Map<String, List<int>> precisionPorLeccion = {};
      final Map<String, String> leccionACurso = {};

      for (final cursoDoc in cursosSnap.docs) {
        final cursoId = cursoDoc.id;
        final histSnap =
            await cursoDoc.reference.collection('historial').get();
        for (final h in histSnap.docs) {
          final d = h.data();
          final aciertos = (d['aciertos'] as num?)?.toInt() ?? 0;
          final total = (d['total'] as num?)?.toInt() ?? 0;
          totalAciertos += aciertos;
          totalErrores += (total - aciertos).clamp(0, total);

          final tiempo = (d['tiempoSegundos'] as num?)?.toInt() ?? 0;
          if (tiempo > 0) {
            totalTiempo += tiempo;
            countTiempo++;
          }

          final leccionId = d['leccionId'] as String?;
          final precision = (d['precision'] as num?)?.toInt();
          if (leccionId != null && precision != null) {
            precisionPorLeccion
                .putIfAbsent(leccionId, () => [])
                .add(precision);
            leccionACurso[leccionId] = cursoId;
          }

          erroresTraducir +=
              (d['erroresTraducir'] as num?)?.toInt() ?? 0;
          erroresCompletar +=
              (d['erroresCompletar'] as num?)?.toInt() ?? 0;
          erroresImagenes +=
              (d['erroresImagenes'] as num?)?.toInt() ?? 0;
        }
      }

      // Weak lessons sorted by avgPrecision ascending
      final leccionesDebiles = precisionPorLeccion.entries
          .map((e) => {
                'leccionId': e.key,
                'cursoId': leccionACurso[e.key] ?? '',
                'avgPrecision':
                    e.value.reduce((a, b) => a + b) ~/ e.value.length,
                'intentos': e.value.length,
              })
          .where((e) => (e['avgPrecision'] as int) < 70)
          .toList()
        ..sort((a, b) =>
            (a['avgPrecision'] as int).compareTo(b['avgPrecision'] as int));

      // Weakest exercise type
      final tiposMap = {
        'leer_escribir': erroresTraducir,
        'completar_frase': erroresCompletar,
        'seleccionar_imagen': erroresImagenes,
      };
      final tipoMasDebil =
          tiposMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

      final totalEj = totalAciertos + totalErrores;
      final precisionGlobal =
          totalEj > 0 ? (totalAciertos / totalEj * 100).round() : 0;

      final nivelSugerido = precisionGlobal >= 80
          ? 'avanzado'
          : precisionGlobal >= 60
              ? 'intermedio'
              : 'basico';

      final tiempoPromedio =
          countTiempo > 0 ? totalTiempo ~/ countTiempo : 0;

      // Pre-fetch exercise IDs from the top weak lessons
      final ejerciciosRepasoIds = <String>{};
      for (final lec in leccionesDebiles.take(5)) {
        final leccionId = lec['leccionId'] as String;
        final cursoId = lec['cursoId'] as String;
        if (cursoId.isEmpty) continue;

        final modulosSnap = await _db
            .collection('cursos')
            .doc(cursoId)
            .collection('modulos')
            .get();

        for (final modDoc in modulosSnap.docs) {
          final lecDoc = await modDoc.reference
              .collection('lecciones')
              .doc(leccionId)
              .get();
          if (lecDoc.exists) {
            final ids = List<String>.from(
              (lecDoc.data() as Map<String, dynamic>)['ejercicios_ids'] ?? [],
            );
            ejerciciosRepasoIds.addAll(ids);
            break;
          }
        }
      }

      await _perfilRef(uid).set({
        'precisionGlobal': precisionGlobal,
        'tiempoPromedioSegundos': tiempoPromedio,
        'leccionesDebiles': leccionesDebiles.take(10).toList(),
        'tiposErrorFrecuentes': {
          'leer_escribir': erroresTraducir,
          'completar_frase': erroresCompletar,
          'seleccionar_imagen': erroresImagenes,
        },
        'tipoMasDebil': tipoMasDebil,
        'nivelDificultadSugerido': nivelSugerido,
        'ejerciciosRepasoIds': ejerciciosRepasoIds.take(50).toList(),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('PerfilAprendizajeService.actualizarPerfil error: $e');
    }
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> obtenerPerfil(String uid) async {
    try {
      final doc = await _perfilRef(uid).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('PerfilAprendizajeService.obtenerPerfil error: $e');
      return null;
    }
  }

  // ── Personalized exercises ─────────────────────────────────────────────────

  // ── Level helpers ─────────────────────────────────────────────────────────

  /// Returns the cumulative list of allowed difficulty levels for a user level.
  static List<String> nivelesPermitidos(String? nivel) {
    switch (nivel) {
      case 'basico+':
        return ['basico', 'basico+'];
      case 'intermedio':
        return ['basico', 'basico+', 'intermedio'];
      case 'avanzado':
        return ['basico', 'basico+', 'intermedio', 'avanzado'];
      default:
        return ['basico'];
    }
  }

  // ── Personalized exercises ─────────────────────────────────────────────────

  /// Returns exercises of the weakest type, filtered by user level,
  /// excluding recently seen ones. Updates seen list for variety.
  static Future<List<EjercicioModel>> ejerciciosPersonalizados(
    String uid, {
    int limite = 15,
    String? nivelUsuario,
  }) async {
    try {
      final perfil = await obtenerPerfil(uid);
      if (perfil == null) return _ejerciciosAleatorios(limite, nivelUsuario);

      final tipoDebil =
          perfil['tipoMasDebil'] as String? ?? 'leer_escribir';
      final recientesRaw =
          perfil['ejerciciosRecientesIds'] as List? ?? [];
      final recientes = recientesRaw.cast<String>().toSet();
      final niveles = nivelesPermitidos(nivelUsuario);

      // Query by weakest type; filter difficulty client-side to avoid
      // requiring a composite index in Firestore.
      final snap = await _db
          .collection('ejercicios')
          .where('tipo_ejercicio', isEqualTo: tipoDebil)
          .limit(60)
          .get();

      var candidatos = snap.docs
          .map((d) => EjercicioModel.fromMap(d.id, d.data()))
          .where((e) =>
              !recientes.contains(e.id) && niveles.contains(e.dificultad))
          .toList()
        ..shuffle(Random());

      // Fill up with other types at the same level if not enough
      if (candidatos.length < limite) {
        final extras =
            await _ejerciciosAleatorios(limite * 2, nivelUsuario);
        final nuevos = extras
            .where((e) =>
                !recientes.contains(e.id) &&
                !candidatos.any((c) => c.id == e.id))
            .toList();
        candidatos.addAll(nuevos);
      }

      final seleccionados = candidatos.take(limite).toList();

      // Persist updated recently-seen list (keep last 80)
      final nuevosIds = seleccionados.map((e) => e.id).toList();
      final nuevaLista =
          <String>{...recientes, ...nuevosIds}.take(80).toList();
      _perfilRef(uid)
          .update({'ejerciciosRecientesIds': nuevaLista})
          .ignore();

      return seleccionados;
    } catch (e) {
      debugPrint(
          'PerfilAprendizajeService.ejerciciosPersonalizados error: $e');
      return _ejerciciosAleatorios(limite, nivelUsuario);
    }
  }

  static Future<List<EjercicioModel>> _ejerciciosAleatorios(
      int limite, String? nivelUsuario) async {
    try {
      final niveles = nivelesPermitidos(nivelUsuario);
      final snap = await _db
          .collection('ejercicios')
          .where('dificultad', whereIn: niveles)
          .limit(limite)
          .get();
      return snap.docs
          .map((d) => EjercicioModel.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
