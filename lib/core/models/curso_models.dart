import 'package:cloud_firestore/cloud_firestore.dart';

class CursoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String nivel;
  final String categoria;
  final String imagenUrl;
  final bool publicado;
  final int modulosCount;
  final int leccionesCount;
  final int ejerciciosCount;
  final int suscritosCount;
  final String creadoPor;
  final DateTime? creadoEn;

  CursoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.nivel,
    required this.imagenUrl,
    required this.publicado,
    this.categoria = 'General',
    this.modulosCount = 0,
    this.leccionesCount = 0,
    this.ejerciciosCount = 0,
    this.suscritosCount = 0,
    this.creadoPor = '',
    this.creadoEn,
  });

  factory CursoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CursoModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      nivel: data['nivel'] ?? '',
      imagenUrl: data['imagen_url'] ?? '',
      publicado: data['publicado'] ?? false,
      categoria: data['categoria'] ?? 'General',
      modulosCount: data['modulos_count'] ?? 0,
      leccionesCount: data['lecciones_count'] ?? 0,
      ejerciciosCount: data['ejercicios_count'] ?? 0,
      suscritosCount: data['suscritos_count'] ?? 0,
      creadoPor: data['creado_por'] ?? '',
      creadoEn: (data['creado_en'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'nivel': nivel,
        'imagen_url': imagenUrl,
        'publicado': publicado,
        'categoria': categoria,
        'modulos_count': modulosCount,
        'lecciones_count': leccionesCount,
        'ejercicios_count': ejerciciosCount,
        'suscritos_count': suscritosCount,
        'creado_por': creadoPor,
      };
}

class ModuloModel {
  final String id;
  final String titulo;
  final String descripcion;
  final int orden;

  ModuloModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
  });

  factory ModuloModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModuloModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      orden: data['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'orden': orden,
      };
}

class LeccionModel {
  final String id;
  final String titulo;
  final String descripcion;
  final int orden;
  final List<String> ejerciciosIds;

  LeccionModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
    this.ejerciciosIds = const [],
  });

  factory LeccionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeccionModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      orden: data['orden'] ?? 0,
      ejerciciosIds: List<String>.from(data['ejercicios_ids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'orden': orden,
        'ejercicios_ids': ejerciciosIds,
      };
}

class EjercicioModel {
  final String id;
  final String tipoEjercicio;
  final String contenido;
  final String dificultad;
  final String respuesta;
  final String pista;
  final String categoria;
  final String vocabId;
  final String imagenUrl;
  final List<dynamic> opciones;
  final String creadoPor;

  EjercicioModel({
    required this.id,
    required this.tipoEjercicio,
    required this.contenido,
    required this.dificultad,
    required this.respuesta,
    required this.pista,
    this.categoria = '',
    this.vocabId = '',
    this.imagenUrl = '',
    this.opciones = const [],
    this.creadoPor = '',
  });

  factory EjercicioModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EjercicioModel(
      id: doc.id,
      tipoEjercicio: data['tipo_ejercicio'] ?? '',
      contenido: data['contenido']?.toString() ?? '',
      dificultad: data['dificultad'] ?? '',
      respuesta: data['respuesta'] ?? '',
      pista: data['pista'] ?? '',
      categoria: data['categoria'] ?? '',
      vocabId: data['vocab_id'] ?? '',
      imagenUrl: data['imagen_url'] ?? '',
      opciones: data['opciones'] ?? [],
      creadoPor: data['creado_por'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'tipo_ejercicio': tipoEjercicio,
        'contenido': contenido,
        'dificultad': dificultad,
        'respuesta': respuesta,
        'pista': pista,
        'categoria': categoria,
        'vocab_id': vocabId,
        'imagen_url': imagenUrl,
        'opciones': opciones,
        'creado_por': creadoPor,
      };
}

class PalabraModel {
  final String id;
  final String categoria;
  final String dificultad;
  final String imagenUrl;
  final String palabraNahuatl;
  final String traduccionEspanol;
  final String varianteNahuatl;

  PalabraModel({
    required this.id,
    required this.categoria,
    required this.dificultad,
    required this.imagenUrl,
    required this.palabraNahuatl,
    required this.traduccionEspanol,
    required this.varianteNahuatl,
  });

  factory PalabraModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PalabraModel(
      id: doc.id,
      categoria: data['categoria'] ?? '',
      dificultad: data['dificultad'] ?? '',
      imagenUrl: data['imagen_url'] ?? '',
      palabraNahuatl: data['palabra_nahuatl'] ?? '',
      traduccionEspanol: data['traduccion_espanol'] ?? '',
      varianteNahuatl: data['variante_nahuatl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'categoria': categoria,
        'dificultad': dificultad,
        'imagen_url': imagenUrl,
        'palabra_nahuatl': palabraNahuatl,
        'traduccion_espanol': traduccionEspanol,
        'variante_nahuatl': varianteNahuatl,
      };
}
