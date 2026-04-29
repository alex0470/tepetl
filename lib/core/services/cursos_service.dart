import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tepetl/core/models/curso_models.dart';

class CursosService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static Stream<List<CursoModel>> streamCursos() {
    return _db.collection('cursos').snapshots().map(
          (snap) => snap.docs.map(CursoModel.fromDoc).toList(),
        );
  }

  static Future<String> crearCurso(CursoModel curso) async {
    final ref = await _db.collection('cursos').add(curso.toMap());
    return ref.id;
  }

  static Future<void> actualizarCurso(
      String cursoId, Map<String, dynamic> data) {
    return _db.collection('cursos').doc(cursoId).update(data);
  }

  static Future<void> eliminarCurso(String cursoId) async {
    final modulos = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .get();
    for (final modDoc in modulos.docs) {
      await eliminarModulo(cursoId, modDoc.id);
    }
    await _db.collection('cursos').doc(cursoId).delete();
  }

  static Future<String> subirImagen(File imagen, String cursoId) async {
    final ref = _storage.ref('cursos/$cursoId/portada.jpg');
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }

  static Stream<List<ModuloModel>> streamModulos(String cursoId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs.map(ModuloModel.fromDoc).toList());
  }

  static Future<void> crearModulo(String cursoId, ModuloModel modulo) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .add(modulo.toMap());
  }

  static Future<void> actualizarModulo(
      String cursoId, String moduloId, Map<String, dynamic> data) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .update(data);
  }

  static Future<void> eliminarModulo(String cursoId, String moduloId) async {
    final lecciones = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .get();
    for (final lecDoc in lecciones.docs) {
      await eliminarLeccion(cursoId, moduloId, lecDoc.id);
    }
    await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .delete();
  }

  static Stream<List<LeccionModel>> streamLecciones(
      String cursoId, String moduloId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs.map(LeccionModel.fromDoc).toList());
  }

  static Future<void> crearLeccion(
      String cursoId, String moduloId, LeccionModel leccion) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .add(leccion.toMap());
  }

  static Future<void> actualizarLeccion(String cursoId, String moduloId,
      String leccionId, Map<String, dynamic> data) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .update(data);
  }

  static Future<void> eliminarLeccion(
      String cursoId, String moduloId, String leccionId) async {
    await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .delete();
  }

  static Future<List<EjercicioModel>> fetchEjerciciosByIds(
      List<String> ids) async {
    if (ids.isEmpty) return [];

    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }

    final results = <EjercicioModel>[];
    for (final chunk in chunks) {
      final snap = await _db
          .collection('ejercicios')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snap.docs.map(EjercicioModel.fromDoc));
    }

    final map = {for (final e in results) e.id: e};
    return ids.map((id) => map[id]).whereType<EjercicioModel>().toList();
  }

  static Stream<List<EjercicioModel>> streamEjerciciosDeLeccion(
      String cursoId, String moduloId, String leccionId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .snapshots()
        .asyncMap((snap) async {
      if (!snap.exists) return <EjercicioModel>[];
      final data = snap.data() as Map<String, dynamic>? ?? {};
      final ids = List<String>.from(data['ejercicios_ids'] ?? []);
      return fetchEjerciciosByIds(ids);
    });
  }

  static Future<void> crearEjercicioEnLeccion(
      String cursoId,
      String moduloId,
      String leccionId,
      EjercicioModel ejercicio) async {
    final ref = await _db.collection('ejercicios').add(ejercicio.toMap());
    await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .update({
      'ejercicios_ids': FieldValue.arrayUnion([ref.id]),
    });
  }

  static Future<void> quitarEjercicioDeLeccion(
      String cursoId,
      String moduloId,
      String leccionId,
      String ejercicioId) async {
    await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .update({
      'ejercicios_ids': FieldValue.arrayRemove([ejercicioId]),
    });
  }

  static Future<void> eliminarEjercicioCompleto(
      String cursoId,
      String moduloId,
      String leccionId,
      String ejercicioId) async {
    await quitarEjercicioDeLeccion(cursoId, moduloId, leccionId, ejercicioId);
    await _db.collection('ejercicios').doc(ejercicioId).delete();
  }

  static Future<void> crearEjercicio(String cursoId, String moduloId,
          String leccionId, EjercicioModel ejercicio) =>
      crearEjercicioEnLeccion(cursoId, moduloId, leccionId, ejercicio);

  static Future<void> eliminarEjercicio(String cursoId, String moduloId,
          String leccionId, String ejercicioId) =>
      eliminarEjercicioCompleto(cursoId, moduloId, leccionId, ejercicioId);

  static Future<int> contarModulos(String cursoId) async {
    final snap = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .count()
        .get();
    return snap.count ?? 0;
  }
}
