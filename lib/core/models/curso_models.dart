import 'package:cloud_firestore/cloud_firestore.dart';

class CursoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String nivel;
  final String imagenUrl;
  final bool publicado;

  CursoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.nivel,
    required this.imagenUrl,
    required this.publicado,
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
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'nivel': nivel,
        'imagen_url': imagenUrl,
        'publicado': publicado,
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
  final List<dynamic> opciones;

  EjercicioModel({
    required this.id,
    required this.tipoEjercicio,
    required this.contenido,
    required this.dificultad,
    required this.respuesta,
    required this.pista,
    this.categoria = '',
    this.vocabId = '',
    this.opciones = const [],
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
      opciones: data['opciones'] ?? [],
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
        'opciones': opciones,
      };
}
