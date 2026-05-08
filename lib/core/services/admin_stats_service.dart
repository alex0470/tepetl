import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tepetl/core/models/curso_models.dart';

class AdminStats {
  final int cursosCreados;
  final int leccionesCreadas;
  final int usuariosActivos;
  final int usuariosNuevos;
  final double tasaCompletacion;

  const AdminStats({
    required this.cursosCreados,
    required this.leccionesCreadas,
    required this.usuariosActivos,
    required this.usuariosNuevos,
    required this.tasaCompletacion,
  });
}

class AdminStatsService {
  static final _db = FirebaseFirestore.instance;

  static Future<AdminStats> cargar(String adminUid) async {
    final now = DateTime.now();
    final hace30 = now.subtract(const Duration(days: 30));
    final hace7  = now.subtract(const Duration(days: 7));

    // Cursos y lecciones del admin
    final cursosSnap = await _db
        .collection('cursos')
        .where('creado_por', isEqualTo: adminUid)
        .get();
    final cursos          = cursosSnap.docs.map(CursoModel.fromDoc).toList();
    final cursosCreados   = cursos.length;
    final leccionesCreadas = cursos.fold<int>(0, (s, c) => s + c.leccionesCount);

    // Usuarios activos (última conexión < 30 días) y nuevos (creados < 7 días)
    final usuariosSnap = await _db.collection('users').get();
    int usuariosActivos = 0;
    int usuariosNuevos  = 0;
    for (final doc in usuariosSnap.docs) {
      final data = doc.data();
      final ultimaConexion = (data['ultima_conexion'] as Timestamp?)?.toDate();
      final createdAt      = (data['createdAt']       as Timestamp?)?.toDate();
      if (ultimaConexion != null && ultimaConexion.isAfter(hace30)) usuariosActivos++;
      if (createdAt != null && createdAt.isAfter(hace7))            usuariosNuevos++;
    }

    // Tasa de completación via collection group
    double tasaCompletacion = 0.0;
    try {
      final totalSnap = await _db
          .collectionGroup('progreso_cursos')
          .count()
          .get();
      final completadosSnap = await _db
          .collectionGroup('progreso_cursos')
          .where('curso_completado', isEqualTo: true)
          .count()
          .get();
      final total      = totalSnap.count ?? 0;
      final completados = completadosSnap.count ?? 0;
      tasaCompletacion  = total > 0 ? completados / total : 0.0;
    } catch (_) {
      tasaCompletacion = 0.0;
    }

    return AdminStats(
      cursosCreados:    cursosCreados,
      leccionesCreadas: leccionesCreadas,
      usuariosActivos:  usuariosActivos,
      usuariosNuevos:   usuariosNuevos,
      tasaCompletacion: tasaCompletacion,
    );
  }
}
