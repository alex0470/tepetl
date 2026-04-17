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

  Future<void> inicializarEstructuraCompleta() async {
    try {
      final batch = _db.batch();

      // 1. CULTURA
      final artRef = _db.collection('articulos_cultura').doc('ejemplo_1');
      batch.set(artRef, {
        'titulo': 'El Origen del Náhuatl',
        'descripcion_corta': 'Una breve introducción a la lengua de los aztecas.',
        'contenido': 'Aquí irá el texto largo del artículo...',
        'imagen_url': 'https://link-a-imagen.com/foto.jpg',
        'fecha_publicacion': FieldValue.serverTimestamp(),
        'autor': 'Admin Tepetl'
      });

      // 2. INSIGNIAS
      final insRef = _db.collection('insignias_y_logros').doc('piedra_solar');
      batch.set(insRef, {
        'titulo': 'Piedra Solar',
        'descripcion': 'Completa tu primera semana de racha.',
        'imagen_url': 'https://link-a-insignia.com/sol.png',
        'xp_recompensa': 100,
        'tipo_condicion': 'racha_7'
      });

      // 3. CURSOS
      final cursoId = 'curso_basico_1';
      final cursoRef = _db.collection('cursos').doc(cursoId);
      batch.set(cursoRef, {
        'titulo': 'Náhuatl para Principiantes',
        'descripcion': 'Aprende las bases de la lengua.',
        'nivel': 'básico',
        'imagen_url': 'https://link-imagen.com/portada.jpg'
      });
      
      final moduloRef = cursoRef.collection('modulos').doc('modulo_1');
      batch.set(moduloRef, {
        'titulo': 'Módulo 1: Saludos',
        'descripcion': 'Primeros pasos para hablar.',
        'orden': 1
      });

      final leccionRef = moduloRef.collection('lecciones').doc('leccion_1');
      batch.set(leccionRef, {
        'titulo': 'Hola y Adiós',
        'descripcion': 'Aprende a saludar.',
        'orden': 1,
        'ejercicios_ids': ['E0001', 'E0002'] 
      });

      await batch.commit();
      print('✅ Estructura base creada en Firebase');

    } catch (e) {
      print('❌ Error al inicializar: $e');
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