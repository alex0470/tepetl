import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class DatosUsuarioPerfil {
  final String nombre;
  final String rol;
  final String nivel;
  final String inicial;
  final String fotoUrl;

  const DatosUsuarioPerfil({
    required this.nombre,
    required this.rol,
    required this.nivel,
    required this.inicial,
    this.fotoUrl = '',
  });
}

class PerfilService {
  static final _db      = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Cargar datos del perfil ───────────────────────────────────────────────

  static Future<DatosUsuarioPerfil?> cargarDatos() async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final nombre = data['nombre'] as String? ?? 'Usuario';

    String rol = data['rol'] as String? ?? 'Estudiante';
    if (rol.isNotEmpty) rol = rol[0].toUpperCase() + rol.substring(1);

    String nivel = data['nivel'] as String? ?? '1';
    if (nivel == 'basico') nivel = 'Básico';
    if (nivel == 'intermedio') nivel = 'Intermedio';

    return DatosUsuarioPerfil(
      nombre:  nombre,
      rol:     rol,
      nivel:   nivel,
      inicial: nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
      fotoUrl: data['foto_url'] as String? ?? '',
    );
  }

  // ── Actualizar nombre ─────────────────────────────────────────────────────

  static Future<void> actualizarNombre(String nombre) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'nombre': nombre.trim()});
  }

  // ── Subir foto de perfil ──────────────────────────────────────────────────

  static Future<String> subirFotoPerfil(XFile xfile) async {
    final uid = _uid;
    if (uid == null) throw Exception('No hay sesión activa');

    final ext = xfile.name.contains('.')
        ? xfile.name.split('.').last.toLowerCase()
        : 'jpg';

    final ref = _storage.ref('users/$uid/profile.$ext');
    final metadata = SettableMetadata(contentType: 'image/$ext');

    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      await ref.putData(bytes, metadata);
    } else {
      await ref.putFile(File(xfile.path), metadata);
    }

    final url = await ref.getDownloadURL();
    await _db.collection('users').doc(uid).update({'foto_url': url});
    return url;
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────────

  static Future<void> cerrarSesion() => FirebaseAuth.instance.signOut();
}
