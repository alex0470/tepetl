import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/models/curso_models.dart';

class CursosService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // ─── Cursos ───────────────────────────────────────────────────────────────

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

  // ─── Storage helpers ─────────────────────────────────────────────────────

  static String _fileExtension(String path) {
    final name = path.split(RegExp(r'[\\/]+')).last;
    return name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
  }

  static String _contentTypeFromExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }

  /// Cross-platform upload using [XFile] (works on Web + Mobile).
  static Future<String> _uploadXFile(
      XFile xfile, String storagePath) async {
    final extension = _fileExtension(xfile.name);
    final metadata = SettableMetadata(
      contentType: _contentTypeFromExtension(extension),
    );
    final ref = _storage.ref('$storagePath.$extension');

    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      await ref.putData(bytes, metadata);
    } else {
      await ref.putFile(File(xfile.path), metadata);
    }

    return ref.getDownloadURL();
  }

  /// Legacy mobile-only upload (kept for backwards-compatibility).
  static Future<String> _uploadFile(File file, String storagePath) async {
    final extension = _fileExtension(file.path);
    final metadata = SettableMetadata(
      contentType: _contentTypeFromExtension(extension),
    );
    final ref = _storage.ref('$storagePath.$extension');
    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }

  // ─── Public upload methods ───────────────────────────────────────────────

  /// Upload course cover image (web-safe, use XFile).
  static Future<String> subirImagenWeb(XFile xfile, String cursoId) =>
      _uploadXFile(xfile, 'cursos/$cursoId/portada');

  /// Upload exercise image (web-safe, use XFile).
  static Future<String> subirImagenEjercicioWeb(
          XFile xfile, String ejercicioId) =>
      _uploadXFile(xfile, 'ejercicios/$ejercicioId/imagen');

  /// Legacy mobile-only methods kept in case they're used elsewhere.
  static Future<String> subirImagen(File imagen, String cursoId) =>
      _uploadFile(imagen, 'cursos/$cursoId/portada');

  static Future<String> subirImagenEjercicio(
          File imagen, String ejercicioId) =>
      _uploadFile(imagen, 'ejercicios/$ejercicioId/imagen');

  static Future<String> subirAudio(File audio, String ejercicioId) =>
      _uploadFile(audio, 'ejercicios/$ejercicioId/audio');

  // ─── Palabras ─────────────────────────────────────────────────────────────

  static Stream<List<PalabraModel>> streamPalabras() {
    return _db.collection('palabras').snapshots().map(
          (snap) => snap.docs.map(PalabraModel.fromDoc).toList(),
        );
  }

  static Future<List<PalabraModel>> getPalabrasByDificultad(
      String dificultad) async {
    final snap = await _db
        .collection('palabras')
        .where('dificultad', isEqualTo: dificultad)
        .get();
    return snap.docs.map(PalabraModel.fromDoc).toList();
  }

  // ─── Módulos ──────────────────────────────────────────────────────────────

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

  static Future<void> eliminarModulo(
      String cursoId, String moduloId) async {
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

  // ─── Lecciones ────────────────────────────────────────────────────────────

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

  // ─── Ejercicios ───────────────────────────────────────────────────────────

  static Future<List<EjercicioModel>> fetchEjerciciosByIds(
      List<String> ids) async {
    if (ids.isEmpty) return [];

    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(
          i, i + 30 > ids.length ? ids.length : i + 30));
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
      final data =
          snap.data() as Map<String, dynamic>? ?? {};
      final ids =
          List<String>.from(data['ejercicios_ids'] ?? []);
      return fetchEjerciciosByIds(ids);
    });
  }

  static Future<void> crearEjercicioEnLeccion(
      String cursoId,
      String moduloId,
      String leccionId,
      EjercicioModel ejercicio) async {
    final ref =
        await _db.collection('ejercicios').add(ejercicio.toMap());
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
    await quitarEjercicioDeLeccion(
        cursoId, moduloId, leccionId, ejercicioId);
    await _db.collection('ejercicios').doc(ejercicioId).delete();
  }

  // Conveniences
  static Future<void> crearEjercicio(String cursoId, String moduloId,
          String leccionId, EjercicioModel ejercicio) =>
      crearEjercicioEnLeccion(cursoId, moduloId, leccionId, ejercicio);

  static Future<void> eliminarEjercicio(String cursoId, String moduloId,
          String leccionId, String ejercicioId) =>
      eliminarEjercicioCompleto(
          cursoId, moduloId, leccionId, ejercicioId);

  // ─── Stats ────────────────────────────────────────────────────────────────

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