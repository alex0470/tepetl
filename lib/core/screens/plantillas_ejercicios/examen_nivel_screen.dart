import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tepetl/core/models/modelo_ejercicio.dart';
import 'package:tepetl/core/models/modelo_revision.dart';
import 'package:tepetl/core/screens/errores/leccion_resumen.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/completar.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/escribir.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/imagenes_ejercicio.dart';
import 'package:tepetl/core/screens/principalesadmin/gestion_usuarios.dart';
import 'package:tepetl/core/services/vidas_service.dart';
import 'package:tepetl/core/widgets/bars/appbar_ejercicios.dart';
import 'dart:math';
import 'package:tepetl/core/widgets/popups/dialogos_utils.dart';

class ExamenNivelScreen extends StatefulWidget {
  const ExamenNivelScreen({super.key});

  @override
  State<ExamenNivelScreen> createState() => _ExamenNivelScreenState();
}

class _ExamenNivelScreenState extends State<ExamenNivelScreen> {
  List<EjercicioModel> _ejercicios = [];
  int _indiceActual = 0;
  bool _isLoading = true;
  int _hearts = 10;
  int _puntaje = 0;

  // --- VARIABLES PARA LA IA ---
  int _aciertosTotales = 0;
  int _vidasPerdidas = 0;
  int _pistasUsadas = 0;
  int _maxRacha = 0;
  int _rachaActual = 0;
  int _erroresTraducir = 0;
  int _erroresCompletar = 0;
  int _erroresImagenes = 0;

  // Cronómetro para medir el tiempo total
  final Stopwatch _cronometro = Stopwatch();

  @override
  void initState() {
    super.initState();
    _cargarCorazones();
    _descargarEjercicios();
    _cronometro.start();
  }

  Future<void> _cargarCorazones() async {
    int corazonesGuardados = await VidasService.obtenerCorazones();
    setState(() {
      _hearts = corazonesGuardados;
    });
    
    // Si entra y ya no tiene vidas, lo sacamos de inmediato
    if (_hearts <= 0) {
      DialogosUtils.mostrarSinCorazones(context);
      return;
    }
  }

  Future<void> _descargarEjercicios() async {
    try {
      int randomNum = Random().nextInt(4000) + 1;
      String randomId = 'E${randomNum.toString().padLeft(4, '0')}';

      final snapshot = await FirebaseFirestore.instance
          .collection('ejercicios')
          .where('dificultad', isEqualTo: 'basico')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: randomId)
          .limit(10)
          .get();

      List<EjercicioModel> listaTemporal = snapshot.docs
          .map((doc) => EjercicioModel.fromMap(doc.id, doc.data()))
          .toList();

      listaTemporal.shuffle();

      setState(() {
        _ejercicios = listaTemporal; 
        _isLoading = false;
      });
    } catch (e) {
      print("Error al descargar ejercicios: $e");
      setState(() => _isLoading = false);
    }
  }

  void _avanzarSiguiente(bool esCorrecto) async {
    // Si la respuesta fue incorrecta, le quitamos un corazón
    if (!esCorrecto) {
      int corazonesRestantes = await VidasService.gastarCorazon();
      
      setState(() {
        _hearts = corazonesRestantes;
      });

      // Si llegó a cero, se acabó el juego
      if (_hearts <= 0) {
        DialogosUtils.mostrarSinCorazones(context);
        return;
      }
    } else {
      // Opcional: Sumar a tu variable _puntaje si acertó
      _puntaje+10; 
    }

    setState(() {
      if (_indiceActual < _ejercicios.length - 1) {
        _indiceActual++;
      } else {
        // 3. NAVEGACIÓN AL RESUMEN: Al terminar el último ejercicio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LeccionResumen(result: ResultadoLeccion(precision: 12, precisionDelta: 12, xpGanada: 12, tiempo: "Doce", mensajeAI: "Doce", errores: [])
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.secundario,)),
      );
    }

    if (_ejercicios.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No se encontraron ejercicios.")),
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
          // 2. INDICADOR ESTILIZADO EN EL BODY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      // Calcula el progreso de 0.0 a 1.0
                      value: (_indiceActual + 1) / _ejercicios.length,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secundario),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "${_indiceActual + 1} / ${_ejercicios.length}",
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

          // El área del ejercicio ocupa el resto de la pantalla
          Expanded(
            child: _construirPlantilla(ejercicioActual),
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
          onCompletado: _avanzarSiguiente,
        );
      case 'completar_frase':
        return PlantillaCompletar(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          onCompletado: _avanzarSiguiente,
        );
      case 'seleccionar_imagen': // Si tienes ejercicios de imagen
        return PlantillaIdentificarImagen(
          key: ValueKey(ejercicio.id),
          ejercicio: ejercicio,
          onCompletado: _avanzarSiguiente,
        );
      default:
        return Center(
          child: Text("Plantilla no soportada: ${ejercicio.tipoEjercicio}"),
        );
    }
  }
}