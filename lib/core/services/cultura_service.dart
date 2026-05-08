import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/models/articulo_cultura_model.dart';

class CulturaService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<ArticuloCulturaModel>> streamArticulos() {
    return _db
        .collection('articulos_cultura')
        .orderBy('fecha_publicacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ArticuloCulturaModel.fromDoc).toList());
  }

  static Future<void> crearArticulo({
    required String titulo,
    required String descripcionCorta,
    required String contenido,
    required String imagenUrl,
    required String autor,
  }) {
    return _db.collection('articulos_cultura').add({
      'titulo': titulo,
      'descripcion_corta': descripcionCorta,
      'contenido': contenido,
      'imagen_url': imagenUrl,
      'autor': autor,
      'fecha_publicacion': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> actualizarArticulo(
    String id,
    Map<String, dynamic> data,
  ) {
    return _db.collection('articulos_cultura').doc(id).update(data);
  }

  static Future<void> eliminarArticulo(String id) {
    return _db.collection('articulos_cultura').doc(id).delete();
  }

  static Future<String> subirImagenArticulo(XFile xfile, String ruta) async {
    final ext = xfile.name.contains('.')
        ? xfile.name.split('.').last.toLowerCase()
        : 'jpg';
    final metadata = SettableMetadata(contentType: 'image/$ext');
    final ref = FirebaseStorage.instance
        .ref('articulos_cultura/$ruta.$ext');

    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      await ref.putData(bytes, metadata);
    } else {
      await ref.putFile(File(xfile.path), metadata);
    }
    return ref.getDownloadURL();
  }
}
