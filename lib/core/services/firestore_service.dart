import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(String uid, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'email': email,
        'rol': 'estudiante',
        'nivel_educativo': 'básico', 
        'xp': 0, 
        'racha_dias': 0,
        'ultima_conexion': FieldValue.serverTimestamp(),
        'insignias_desbloqueadas': [], 
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompletado': false,
        'nivel_seleccionado': false,
      });
      
      await _db
          .collection('users')
          .doc(uid)
          .collection('progreso_cursos')
          .doc('curso_basico_1') 
          .set({
        'lecciones_completadas': [],
        'curso_completado': false,
      });

      print('✅ Usuario creado con gamificación completa');
    } catch (e) {
      print('❌ Error al guardar usuario: $e');
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

  Future<void> actualizarUsuariosAntiguos() async {
    try {
      final usuariosSnapshot = await _db.collection('users').get();
      final batch = _db.batch();

      for (var doc in usuariosSnapshot.docs) {
        final data = doc.data();
        
        if (data['xp'] == null) {
          batch.update(doc.reference, {
            'nivel_educativo': 'básico',
            'xp': 0,
            'racha_dias': 0,
            'insignias_desbloqueadas': [],
            'rol': data['rol'] ?? 'estudiante',
          });

          final progresoRef = doc.reference
              .collection('progreso_cursos')
              .doc('curso_basico_1');
          
          batch.set(progresoRef, {
            'lecciones_completadas': [],
            'curso_completado': false,
          });
        }
      }

      await batch.commit();
      print('✅ Todos los usuarios antiguos han sido actualizados');
    } catch (e) {
      print('❌ Error actualizando usuarios: $e');
    }
  }

  // OBTENER ROL DEL USUARIO
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['rol'] ?? 'estudiante'; 
      }
    } catch (e) {
      print('❌ Error al obtener rol: $e');
    }
    return 'estudiante'; 
  }

  // CREAR EJERCICIO (Corregido a 'ejercicios')
  Future<void> createExercise(Map<String, dynamic> data) async {
    await _db.collection('ejercicios').add(data);
  }

  // OBTENER EJERCICIOS (Corregido a 'ejercicios')
  Stream<QuerySnapshot> getExercises() {
    return _db.collection('ejercicios').snapshots();
  }
}