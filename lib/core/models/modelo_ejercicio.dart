class EjercicioModel {
  final String id;
  final String tipoEjercicio;
  final String vocabId;
  final String contenido;
  final String respuesta;
  final List<String> opciones;
  final String categoria;
  final String dificultad;
  final String pista;
  final String creadoPor;

  EjercicioModel({
    required this.id,
    required this.tipoEjercicio,
    required this.vocabId,
    required this.contenido,
    required this.respuesta,
    required this.opciones,
    required this.categoria,
    required this.dificultad,
    required this.pista,
    required this.creadoPor,
  });

  // Convierte los datos de Firestore a tu objeto
  factory EjercicioModel.fromMap(String documentId, Map<String, dynamic> data) {
    return EjercicioModel(
      id: documentId,
      tipoEjercicio: data['tipo_ejercicio'] ?? '',
      vocabId: data['vocab_id'] ?? '',
      contenido: data['contenido'] ?? '',
      respuesta: data['respuesta'] ?? '',
      opciones: List<String>.from(data['opciones'] ?? []), 
      categoria: data['categoria'] ?? '',
      dificultad: data['dificultad'] ?? 'basico',
      pista: data['pista'] ?? '',
      creadoPor: data['creado_por'] ?? '',
    );
  }

  // Convierte el objeto a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'tipo_ejercicio': tipoEjercicio,
      'vocab_id': vocabId,
      'contenido': contenido,
      'respuesta': respuesta,
      'opciones': opciones,
      'categoria': categoria,
      'dificultad': dificultad,
      'pista': pista,
      'creado_por': creadoPor,
    };
  }
}