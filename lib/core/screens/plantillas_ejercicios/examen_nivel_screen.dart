import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tepetl/core/models/modelo_ejercicio.dart';
import 'package:tepetl/core/models/modelo_revision.dart';
import 'package:tepetl/core/screens/errores/leccion_resumen.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/completar.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/escribir.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/imagenes_ejercicio.dart';
import 'package:tepetl/core/services/ia_service.dart';
import 'package:tepetl/core/services/vidas_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/bars/appbar_ejercicios.dart';
import 'dart:math';
import 'package:tepetl/core/widgets/popups/dialogos_utils.dart';

class ExamenNivelScreen extends StatefulWidget {
  const ExamenNivelScreen({super.key});

  @override
  State<ExamenNivelScreen> createState() => _ExamenNivelScreenState();
}

class _ExamenNivelScreenState extends State<ExamenNivelScreen> {
  //Ejercicios
  List<EjercicioModel> _ejercicios = [];
  int _indiceActual = 0;
  bool _isLoading = true;
  bool _finalizando = false;

  //Vidas
  int _hearts = 20;

  //Métricas para la IA
  int _aciertosTotales = 0;
  int _vidasPerdidas = 0;
  int _pistasUsadas = 0;
  int _maxRacha = 0;
  int _rachaActual = 0;
  int _erroresTraducir = 0;
  int _erroresCompletar = 0;
  int _erroresImagenes = 0;

  // Lista de ejercicios fallados para RevisionErrores
  final List<EjercicioModel> _errores = [];

  // Cronómetro
  final Stopwatch _cronometro = Stopwatch();

  @override
  void initState() {
    super.initState();
    _cargarCorazones();
    _descargarEjercicios();
    _cronometro.start();
  }

  //Carga de corazones
  Future<void> _cargarCorazones() async {
    final corazonesGuardados = await VidasService.obtenerCorazones();
    setState(() => _hearts = corazonesGuardados);

    if (_hearts <= 0) {
      if (mounted) DialogosUtils.mostrarSinCorazones(context);
    }
  }

  // Cursos base del examen de nivelación: 5 ejercicios de cada uno → 10 en total.
  static const _cursosExamen = ['Cantidades', 'Colores'];
  static const _porCurso = 5;

  static String _normNivel(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  /// Descarga ejercicios de los cursos "Cantidades — Básico" y "Colores — Básico".
  /// Recorre modulos → lecciones → ejercicios_ids y selecciona 5 al azar de cada curso.
  Future<void> _descargarEjercicios() async {
    try {
      final db  = FirebaseFirestore.instance;
      final rng = Random();
      final List<String> idsMuestra = [];

      for (final prefijo in _cursosExamen) {
        // Búsqueda por prefijo de título (no requiere índice compuesto)
        final cursosSnap = await db
            .collection('cursos')
            .where('titulo', isGreaterThanOrEqualTo: prefijo)
            .where('titulo', isLessThan: '$prefijo')
            .get();

        final List<String> idsDelCurso = [];

        for (final cursoDoc in cursosSnap.docs) {
          // Filtrar client-side por nivel básico (normalizado)
          final nivel = _normNivel(
            (cursoDoc.data()['nivel'] as String? ?? ''),
          );
          if (nivel != 'basico') continue;

          // Recorrer módulos → lecciones → ejercicios_ids
          final modulos = await cursoDoc.reference.collection('modulos').get();
          for (final moduloDoc in modulos.docs) {
            final lecciones =
                await moduloDoc.reference.collection('lecciones').get();
            for (final leccionDoc in lecciones.docs) {
              final ids = List<String>.from(
                leccionDoc.data()['ejercicios_ids'] ?? [],
              );
              idsDelCurso.addAll(ids);
            }
          }
        }

        // 5 aleatorios de este curso
        idsDelCurso.shuffle(rng);
        idsMuestra.addAll(idsDelCurso.take(_porCurso));
      }

      if (idsMuestra.isEmpty) {
        debugPrint('Examen: no se encontraron IDs en los cursos base.');
        setState(() => _isLoading = false);
        return;
      }

      // Fetch de ejercicios (máx 10 IDs, dentro del límite whereIn: 30)
      idsMuestra.shuffle(rng);
      final snap = await db
          .collection('ejercicios')
          .where(FieldPath.documentId, whereIn: idsMuestra)
          .get();

      final ejercicios = snap.docs
          .map((d) => EjercicioModel.fromMap(d.id, d.data()))
          .toList()
        ..shuffle(rng);

      setState(() {
        _ejercicios = ejercicios;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al descargar ejercicios: $e');
      setState(() => _isLoading = false);
    }
  }

  //Callback principal al terminar un ejercicio
  /// [esCorrecto] – si acertó
  /// [pistaUsada] - si el usuario utilizó la pista en este ejercicio
  /// [tipo]       – 'leer_escribir' | 'completar_frase' | 'seleccionar_imagen'
  void _avanzarSiguiente(bool esCorrecto, bool pistaUsada, String tipo) async {
    // 1. Registrar si usó pista
    if (pistaUsada) {
      _pistasUsadas++;
    }

    if (esCorrecto) {
      _aciertosTotales++;
      _rachaActual++;
      if (_rachaActual > _maxRacha) _maxRacha = _rachaActual;
    } else {
      _vidasPerdidas++; 
      _rachaActual = 0;
      
      final ejercicioActual = _ejercicios[_indiceActual];
      _errores.add(ejercicioActual);

      switch (tipo) {
        case 'leer_escribir':
          _erroresTraducir++;
          break;
        case 'completar_frase':
          _erroresCompletar++;
          break;
        case 'seleccionar_imagen':
          _erroresImagenes++;
          break;
      }

      // Gastar corazón
      final corazonesRestantes = await VidasService.gastarCorazon();
      setState(() => _hearts = corazonesRestantes);

      if (_hearts <= 0) {
        if (mounted) {
          DialogosUtils.mostrarSinCorazones(context);
        }
        return;
      }
    }

    if (_indiceActual < _ejercicios.length - 1) {
      setState(() => _indiceActual++);
    } else {
      _finalizarExamen();
    }
  }

  Future<void> _finalizarExamen() async {
    if (_finalizando) return;
    setState(() {
      _finalizando = true;
    });
    _cronometro.stop();

    final int totalEjercicios = _ejercicios.length;
    final int tiempoSegundos = _cronometro.elapsed.inSeconds;

    final Map<String, dynamic> resultadoIA = await IAService.evaluarExamen(
      aciertosTotales: _aciertosTotales,
      totalEjercicios: totalEjercicios,
      vidasPerdidas: _vidasPerdidas,
      pistasUsadas: _pistasUsadas,
      maxRacha: _maxRacha,
      erroresTraducir: _erroresTraducir,
      erroresCompletar: _erroresCompletar,
      erroresImagenes: _erroresImagenes,
      tiempoSegundos: tiempoSegundos,
    );

    final String mensajeAI =
        resultadoIA['mensaje_ai'] as String? ?? 'Buen esfuerzo.';
    
    final int precision =
        (resultadoIA['precision'] as num?)?.toInt() ??
            ((totalEjercicios > 0
                    ? (_aciertosTotales / totalEjercicios * 100)
                    : 0)
                .round());
                
    final int xpGanada = (resultadoIA['xp'] as num?)?.toInt() ??
        ((totalEjercicios * 10 * precision) ~/ 100).clamp(5, totalEjercicios * 10);

    final String nivelDeterminado = resultadoIA['nivel_predicho'] ?? 
                                    resultadoIA['nivel'] ?? 
                                    'basico';

    await _actualizarNivelFirestore(nivelDeterminado);

    final int minutos = tiempoSegundos ~/ 60;
    final int segundos = tiempoSegundos % 60;
    final String tiempoFormateado =
        '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LeccionResumen(
          result: ResultadoLeccion(
            precision: precision,
            precisionDelta: precision, 
            xpGanada: xpGanada,
            tiempo: tiempoFormateado,
            mensajeAI: mensajeAI,
            errores: [],
          ),
        ),
      ),
    );
  }

  Future<void> _actualizarNivelFirestore(String nuevoNivel) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'nivel_educativo': nuevoNivel,   // Campo requerido 1
        'nivel_seleccionado': true,      // Campo requerido 2
        'ultimo_examen': FieldValue.serverTimestamp(),
        'aciertos_ultimo_examen': _aciertosTotales,
        'precision_ultimo_examen':
            _ejercicios.isNotEmpty
                ? (_aciertosTotales / _ejercicios.length * 100).round()
                : 0,
      });

      debugPrint('Nivel IA actualizado a: $nuevoNivel');
    } catch (e) {
      debugPrint('Error actualizando nivel en Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secundario),
        ),
      );
    }

    if (_ejercicios.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No se encontraron ejercicios.')),
      );
    }

    final ejercicioActual = _ejercicios[_indiceActual];

    return Scaffold(
      body: Column(
        children: [
          AppbarEjercicios(
            title: ejercicioActual.categoria.toUpperCase(),
            hearts: _hearts,
            onClose: () => Navigator.of(context).pop(),
          ),

          // Barra de progreso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_indiceActual + 1) / _ejercicios.length,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secundario),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  '${_indiceActual + 1} / ${_ejercicios.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Área del ejercicio
          Expanded(
            child: _finalizando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.secundario),
                  )
                : _construirPlantilla(ejercicioActual),
          ),
        ],
      ),
    );
  }

  Widget _construirPlantilla(EjercicioModel ejercicio) {
    switch (ejercicio.tipoEjercicio) {
      case 'leer_escribir':
        return PlantillaEscribir(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          // Ya no pasamos onPistaUsada independiente
          onCompletado: (esCorrecto, pistaUsada, _, _) =>
              _avanzarSiguiente(esCorrecto, pistaUsada, 'leer_escribir'),
        );

      case 'completar_frase':
        return PlantillaCompletar(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          onCompletado: (esCorrecto, pistaUsada, _, _) =>
              _avanzarSiguiente(esCorrecto, pistaUsada, 'completar_frase'),
        );

      case 'seleccionar_imagen':
        return PlantillaIdentificarImagen(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          onCompletado: (esCorrecto, pistaUsada, _, _) =>
              _avanzarSiguiente(esCorrecto, pistaUsada, 'seleccionar_imagen'),
        );

      default:
        return Center(
          child:
              Text('Plantilla no soportada: ${ejercicio.tipoEjercicio}'),
        );
    }
  }
}