import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // GUARDAR USUARIO
  Future<void> saveUser(String uid, String email) async {
  try {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('✅ saveUser OK');
  } catch (e) {
    print('❌ saveUser error: $e');
  }
}

Future<void> updateUser(String uid, Map<String, dynamic> data) async {
  try {
    await _db.collection('users').doc(uid).update(data);
    print('✅ updateUser OK');
  } catch (e) {
    print('❌ updateUser error: $e');
  }
}

Future<void> updateUserLevel(String uid, String level) async {
  await _db.collection('users').doc(uid).update({
    'nivel': level,
  });
}

// OBTENER ROL DEL USUARIO
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['rol'] ?? 'estudiante'; // Devuelve el rol o 'estudiante' si no existe
      }
    } catch (e) {
      print('❌ Error al obtener rol: $e');
    }
    return 'estudiante'; // Por seguridad, si falla, es estudiante
  }

  // CREAR EJERCICIO (esto te sirve mucho)
  Future<void> createExercise(Map<String, dynamic> data) async {
    await _db.collection('exercises').add(data);
  }

  // OBTENER EJERCICIOS
  Stream<QuerySnapshot> getExercises() {
    return _db.collection('exercises').snapshots();
  }
}