import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatosUsuarioPerfil {
  final String nombre;
  final String rol;
  final String nivel;
  final String inicial;

  const DatosUsuarioPerfil({
    required this.nombre,
    required this.rol,
    required this.nivel,
    required this.inicial,
  });
}

class PerfilService {
  static Future<DatosUsuarioPerfil?> cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final nombre = data['nombre'] as String? ?? 'Usuario';

    String rol = data['rol'] as String? ?? 'Estudiante';
    if (rol.isNotEmpty) rol = rol[0].toUpperCase() + rol.substring(1);

    String nivel = data['nivel'] as String? ?? '1';
    if (nivel == 'basico') nivel = 'Básico';
    if (nivel == 'intermedio') nivel = 'Intermedio';

    return DatosUsuarioPerfil(
      nombre: nombre,
      rol: rol,
      nivel: nivel,
      inicial: nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
    );
  }

  static Future<void> cerrarSesion() => FirebaseAuth.instance.signOut();
}
