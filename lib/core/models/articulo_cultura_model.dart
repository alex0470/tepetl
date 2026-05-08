import 'package:cloud_firestore/cloud_firestore.dart';

class ArticuloCulturaModel {
  final String id;
  final String titulo;
  final String descripcionCorta;
  final String contenido;
  final String imagenUrl;
  final String autor;
  final DateTime? fechaPublicacion;

  const ArticuloCulturaModel({
    required this.id,
    required this.titulo,
    required this.descripcionCorta,
    required this.contenido,
    required this.imagenUrl,
    required this.autor,
    this.fechaPublicacion,
  });

  String get duracion {
    final words = contenido.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return '${(words / 200).ceil().clamp(1, 60)} min';
  }

  factory ArticuloCulturaModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticuloCulturaModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcionCorta: data['descripcion_corta'] ?? '',
      contenido: data['contenido'] ?? '',
      imagenUrl: data['imagen_url'] ?? '',
      autor: data['autor'] ?? 'Admin Tepetl',
      fechaPublicacion: (data['fecha_publicacion'] as Timestamp?)?.toDate(),
    );
  }
}
