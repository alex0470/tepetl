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
    );
  }
}