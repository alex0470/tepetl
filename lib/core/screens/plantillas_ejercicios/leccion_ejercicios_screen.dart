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
import 'package:tepetl/core/services/meta_diaria_service.dart';
import 'package:tepetl/core/services/progreso_service.dart';
import 'package:tepetl/core/services/vidas_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/bars/appbar_ejercicios.dart';
import 'package:tepetl/core/widgets/popups/dialogos_utils.dart';

class LeccionEjerciciosScreen extends StatefulWidget {
  final String cursoId;
  final String leccionId;
  final String? moduloId;
  final String leccionTitulo;
  final List<String> ejerciciosIds;
  final List<EjercicioModel>? ejerciciosDirectos;
  final int totalLeccionesCurso;

  const LeccionEjerciciosScreen({
    super.key,
    required this.cursoId,
    required this.leccionId,
    this.moduloId,
    required this.leccionTitulo,
    required this.ejerciciosIds,
    this.ejerciciosDirectos,
    this.totalLeccionesCurso = 1,
  });

  @override
  State<LeccionEjerciciosScreen> createState() =>
      _LeccionEjerciciosScreenState();
}

// Registro interno de cada intento de ejercicio
class _EjercicioIntento {
  final String tipo;
  final String contenido;
  final String respuestaUsuario;
  final String respuestaCorrecta;
  final bool esCorrecta;
  String retroalimentacion;

  _EjercicioIntento({
    required this.tipo,
    required this.contenido,
    required this.respuestaUsuario,
    required this.respuestaCorrecta,
    required this.esCorrecta,
    this.retroalimentacion = '',
  });
}

class _LeccionEjerciciosScreenState extends State<LeccionEjerciciosScreen> {
  List<EjercicioModel> _ejercicios = [];
  int _indiceActual = 0;
  bool _isLoading = true;
  bool _finalizando = false;
  int _hearts = 20;
  int _aciertosTotales = 0;
  int _vidasPerdidas = 0;
  int _pistasUsadas = 0;
  int _maxRacha = 0;
  int _rachaActual = 0;
  int _erroresTraducir = 0;
  int _erroresCompletar = 0;
  int _erroresImagenes = 0;
  int _tiempoInicialSegundos = 0;
  final List<_EjercicioIntento> _intentos = [];

  final Stopwatch _cronometro = Stopwatch();

  @override
  void initState() {
    super.initState();
    _cargarCorazones();
    _cargarEjercicios();
    _cargarEstadoParcial();
    _cronometro.start();
  }

  Future<void> _cargarCorazones() async {
    final corazonesGuardados = await VidasService.obtenerCorazones();
    setState(() => _hearts = corazonesGuardados);

    if (_hearts <= 0 && mounted) {
      DialogosUtils.mostrarSinCorazones(context);
    }
  }

  Future<void> _cargarEstadoParcial() async {
    if (widget.cursoId == 'sugerencias') return;

    final parcial = await ProgresoService.obtenerEstadoParcial(
        widget.cursoId, widget.leccionId);
    if (parcial != null && mounted) {
      setState(() {
        _indiceActual = parcial['indiceActual'] ?? 0;
        _aciertosTotales = parcial['aciertosTotales'] ?? 0;
        _vidasPerdidas = parcial['vidasPerdidas'] ?? 0;
        _pistasUsadas = parcial['pistasUsadas'] ?? 0;
        _maxRacha = parcial['maxRacha'] ?? 0;
        _rachaActual = parcial['rachaActual'] ?? 0;
        _erroresTraducir = parcial['erroresTraducir'] ?? 0;
      _erroresCompletar = parcial['erroresCompletar'] ?? 0;
      _erroresImagenes = parcial['erroresImagenes'] ?? 0;
      _tiempoInicialSegundos = parcial['tiempoSegundos'] ?? 0;
    });
    // Mostrar snackbar de "continuando donde lo dejaste"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Continuando donde lo dejaste...')),
        );
      }
    });
  }
}

  Future<void> _cargarEjercicios() async {
    if (widget.ejerciciosDirectos != null) {
      setState(() {
        _ejercicios = widget.ejerciciosDirectos!;
        _isLoading = false;
      });
      return;
    }

    try {
      List<EjercicioModel> listaTemporal = [];

      if (widget.ejerciciosIds.isNotEmpty) {
        final chunks = _chunkList(widget.ejerciciosIds, 30);

        for (final chunk in chunks) {
          final snapshot = await FirebaseFirestore.instance
              .collection('ejercicios')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          listaTemporal.addAll(
            snapshot.docs
                .map((doc) => EjercicioModel.fromMap(doc.id, doc.data())),
          );
        }

        final ordenMap = {
          for (var i = 0; i < widget.ejerciciosIds.length; i++)
            widget.ejerciciosIds[i]: i
        };
        listaTemporal.sort(
          (a, b) =>
              (ordenMap[a.id] ?? 999).compareTo(ordenMap[b.id] ?? 999),
        );
      } else {
        final query = FirebaseFirestore.instance
            .collection('ejercicios')
            .where('cursoId', isEqualTo: widget.cursoId);

        final snapshot = widget.moduloId != null
            ? await query
                .where('moduloId', isEqualTo: widget.moduloId)
                .where('leccionId', isEqualTo: widget.leccionId)
                .limit(15)
                .get()
            : await query
                .where('leccionId', isEqualTo: widget.leccionId)
                .limit(15)
                .get();

        listaTemporal = snapshot.docs
            .map((doc) => EjercicioModel.fromMap(doc.id, doc.data()))
            .toList();
      }

      setState(() {
        _ejercicios = listaTemporal;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar ejercicios de lección: $e');
      setState(() => _isLoading = false);
    }
  }

  void _avanzarSiguiente(
      bool esCorrecto, bool pistaUsada, String tipo,
      String respuestaUsuario, String respuestaCorrecta) async {
    if (pistaUsada) _pistasUsadas++;

    final ejercicioActual = _ejercicios[_indiceActual];

    // Registrar intento
    final intento = _EjercicioIntento(
      tipo: tipo,
      contenido: ejercicioActual.contenido,
      respuestaUsuario: respuestaUsuario,
      respuestaCorrecta: respuestaCorrecta,
      esCorrecta: esCorrecto,
    );
    _intentos.add(intento);

    // La retroalimentación por ejercicio se muestra en el RespuestaSheet
    // (manejada directamente en cada widget de ejercicio)

    if (esCorrecto) {
      _aciertosTotales++;
      _rachaActual++;
      if (_rachaActual > _maxRacha) _maxRacha = _rachaActual;
    } else {
      _vidasPerdidas++;
      _rachaActual = 0;

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

      final corazonesRestantes = await VidasService.gastarCorazon();
      setState(() => _hearts = corazonesRestantes);

      if (_hearts <= 0 && mounted) {
        DialogosUtils.mostrarSinCorazones(context);
        return;
      }
    }

    if (_indiceActual < _ejercicios.length - 1) {
      setState(() => _indiceActual++);
    } else {
      _finalizarLeccion();
    }
  }

  Future<void> _finalizarLeccion() async {
    if (_finalizando) return;
    setState(() => _finalizando = true);
    _cronometro.stop();

    final int totalEjercicios = _ejercicios.length;
    final int tiempoSegundos =
        _cronometro.elapsed.inSeconds + _tiempoInicialSegundos;

    // 1. Calcular precisión y XP localmente (sin llamar a /predecir)
    final int precision = totalEjercicios > 0
        ? (_aciertosTotales / totalEjercicios * 100).round()
        : 0;

    final int xpGanada =
        ((_ejercicios.length * 10 * precision) ~/ 100)
            .clamp(5, _ejercicios.length * 10);

    // 2. Retroalimentación detallada por sesión
    // Se envían TODOS los intentos para que Gemini tenga contexto completo
    final List<_EjercicioIntento> errores =
        _intentos.where((i) => !i.esCorrecta).toList();

    final Map<String, dynamic> retro = await IAService.obtenerRetroalimentacion(
      precision: precision,
      aciertos: _aciertosTotales,
      total: totalEjercicios,
      tiempoSegundos: tiempoSegundos,
      errores: _intentos                    // todos, no solo los incorrectos
          .map((i) => {
                'tipo': i.tipo,
                'respuesta_usuario': i.respuestaUsuario,
                'respuesta_correcta': i.respuestaCorrecta,
              })
          .toList(),
    );

    final String mensajeAI = (retro['resumen'] as String?)?.isNotEmpty == true
        ? retro['resumen'] as String
        : precision == 100
            ? '¡Perfecto! Completaste la lección sin errores. ¡Excelente trabajo!'
            : 'Completaste la lección con $precision% de precisión. ¡Sigue practicando!';

    // 3. Construir lista de errores usando la nota de /evaluar-ejercicio
    //    (ya almacenada en intento.retroalimentacion) como fuente principal
    final List<LeccionErrores> leccionErrores = errores
        .map((intento) {
          final nota = intento.retroalimentacion.isNotEmpty
              ? intento.retroalimentacion
              : 'Revisa la respuesta correcta: "${intento.respuestaCorrecta}".';
          final tipo = _tipoErrorDesde(intento.tipo);
          return LeccionErrores(
            tipo: tipo,
            contenido: intento.contenido,
            respuestaUsuario: intento.respuestaUsuario,
            respuestaCorrecta: intento.respuestaCorrecta,
            notaAI: nota,
          );
        })
        .toList();

    // 4. Guardar progreso
    await _guardarProgresoLeccion(precision, xpGanada);

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
            errores: leccionErrores,
          ),
        ),
      ),
    );

    await MetaDiariaService.registrarSesion(_cronometro.elapsed.inSeconds);
  }

  Future<void> _guardarProgresoLeccion(int precision, int xpGanada) async {
    if (widget.cursoId == 'sugerencias') return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final progresoRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('progreso')
          .doc(widget.cursoId);
      
      final totalLecciones = widget.ejerciciosIds.isNotEmpty
      ? widget.ejerciciosIds.length  // No es exacto, ver nota abajo
      : _ejercicios.length;

      // Lección completada si precisión >= 70%
      final bool leccionCompletada = precision >= 70;

      await ProgresoService.guardarLeccionCompletada(
        cursoId: widget.cursoId,
        leccionId: widget.leccionId,
        totalLeccionesCurso: widget.totalLeccionesCurso, // nuevo parámetro
        precision: precision,
        xpGanada: xpGanada,
        aciertos: _aciertosTotales,
        total: _ejercicios.length,
      );

      await progresoRef.set({
        'cursoId': widget.cursoId,
        if (widget.moduloId != null) 'moduloId': widget.moduloId,
        'leccionesCompletadas': FieldValue.arrayUnion(
          leccionCompletada ? [widget.leccionId] : [],
        ),
        'ultimaLeccion': widget.leccionId,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
        // Métricas acumuladas por lección
        'lecciones': {
          widget.leccionId: {
            'completada': leccionCompletada,
            'precision': precision,
            'aciertos': _aciertosTotales,
            'total': _ejercicios.length,
            'fecha': FieldValue.serverTimestamp(),
          }
        },
      }, SetOptions(merge: true));

      debugPrint(
          'Progreso guardado — lección ${widget.leccionId}, precisión: $precision%');
    } catch (e) {
      debugPrint('Error guardando progreso de lección: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  TipoError _tipoErrorDesde(String tipo) {
    switch (tipo) {
      case 'gramatica':
        return TipoError.gramatica;
      case 'sintaxis':
        return TipoError.sintaxis;
      case 'completar_frase':
        return TipoError.gramatica;
      default:
        return TipoError.vocabulario;
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.secundario),
              const SizedBox(height: 16),
              Text(
                'Cargando ejercicios…',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_ejercicios.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.leccionTitulo)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'No se encontraron ejercicios\npara esta lección.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final ejercicioActual = _ejercicios[_indiceActual];

    return Scaffold(
      body: Column(
        children: [
          // AppBar con título de la lección y corazones
          AppbarEjercicios(
            title: widget.leccionTitulo.toUpperCase(),
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
          onCompletado: (esCorrecto, pistaUsada, respUsuario, respCorrecta) =>
              _avanzarSiguiente(esCorrecto, pistaUsada, 'leer_escribir', respUsuario, respCorrecta),
        );

      case 'completar_frase':
        return PlantillaCompletar(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          onCompletado: (esCorrecto, pistaUsada, respUsuario, respCorrecta) =>
              _avanzarSiguiente(esCorrecto, pistaUsada, 'completar_frase', respUsuario, respCorrecta),
        );

      case 'seleccionar_imagen':
        return PlantillaIdentificarImagen(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          onCompletado: (esCorrecto, pistaUsada, respUsuario, respCorrecta) =>
              _avanzarSiguiente(esCorrecto, pistaUsada, 'seleccionar_imagen', respUsuario, respCorrecta),
        );

      default:
        return Center(
          child: Text('Plantilla no soportada: ${ejercicio.tipoEjercicio}'),
        );
    }
  }
}