// lesson_models.dart
// Modelos de datos compartidos entre pantallas

enum TipoError { gramatica, vocabulario, sintaxis }

class LeccionErrores {
  final TipoError tipo;
  final String contenido;
  final String respuestaUsuario;
  final String respuestaCorrecta;
  final String notaAI;

  const LeccionErrores({
    required this.tipo,
    this.contenido = '',
    required this.respuestaUsuario,
    required this.respuestaCorrecta,
    required this.notaAI,
  });

  String get tipoLabel {
    switch (tipo) {
      case TipoError.gramatica:
        return 'GRAMÁTICA';
      case TipoError.vocabulario:
        return 'VOCABULARIO';
      case TipoError.sintaxis:
        return 'SINTAXIS';
    }
  }
}

class ResultadoLeccion {
  final int precision; 
  final int precisionDelta;
  final int xpGanada;
  final String tiempo;
  final String mensajeAI;
  final List<LeccionErrores> errores;

  const ResultadoLeccion({
    required this.precision,
    required this.precisionDelta,
    required this.xpGanada,
    required this.tiempo,
    required this.mensajeAI,
    required this.errores,
  });
}

// Datos de ejemplo — reemplaza con tus datos reales
final exampleLessonResult = ResultadoLeccion(
  precision: 88,
  precisionDelta: 2,
  xpGanada: 25,
  tiempo: '4:32',
  mensajeAI:
      'Tu pronunciación de las oclusivas ha mejorado un 18%. Enfócate en el sufijo -li en tu próxima sesión.',
  errores: [
    LeccionErrores(
      tipo: TipoError.gramatica,
      respuestaUsuario: 'Tiazohtia',
      respuestaCorrecta: 'Nitlazohtia',
      notaAI:
          'Recuerda que en Náhuatl, los verbos siempre necesitan un prefijo de sujeto. Para "Yo amo", usa el prefijo ni- antes de la raíz verbal.',
    ),
    LeccionErrores(
      tipo: TipoError.vocabulario,
      respuestaUsuario: 'Calli',
      respuestaCorrecta: 'Kalli',
      notaAI:
          'Aunque "Calli" es común en textos antiguos, en esta lección estamos usando la ortografía moderna estandarizada que prefiere la k para este sonido.',
    ),
    LeccionErrores(
      tipo: TipoError.sintaxis,
      respuestaUsuario: 'El-hombre-come',
      respuestaCorrecta: 'Tlacua in tlacatl',
      notaAI:
          'El Náhuatl clásico a menudo coloca el verbo al principio de la frase para dar énfasis a la acción.',
    ),
  ],
);