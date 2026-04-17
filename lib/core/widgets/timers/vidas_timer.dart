import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tepetl/core/services/vidas_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class WidgetCorazonesTimer extends StatefulWidget {
  const WidgetCorazonesTimer({super.key});

  @override
  State<WidgetCorazonesTimer> createState() => _WidgetCorazonesTimerState();
}

class _WidgetCorazonesTimerState extends State<WidgetCorazonesTimer> {
  int _corazones = 10;
  Duration _tiempoRestante = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _actualizarDatos();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _actualizarDatos();
    });
  }

  Future<void> _actualizarDatos() async {
    int cor = await VidasService.obtenerCorazones();
    Duration tiempo = await VidasService.tiempoParaSiguienteCorazon();
    
    if (mounted) {
      setState(() {
        _corazones = cor;
        _tiempoRestante = tiempo;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Definimos si está sin vidas
    final bool sinVidas = _corazones <= 0;

    // 2. Definimos los colores dinámicos
    final Color colorPrincipal = sinVidas ? Colors.grey : AppColors.rojo1;
    final Color colorFondo = sinVidas 
        ? Colors.grey.withValues(alpha: 0.1) 
        : AppColors.rojo1.withValues(alpha: 0.1);
    final Color colorBorde = sinVidas 
        ? Colors.grey.withValues(alpha: 0.4) 
        : Colors.white.withValues(alpha: 0.3);

    // Función para el formato del tiempo
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    String minutos = dosDigitos(_tiempoRestante.inMinutes.remainder(60));
    String segundos = dosDigitos(_tiempoRestante.inSeconds.remainder(60));

    return AnimatedContainer( // Cambiamos a AnimatedContainer para que el cambio de color sea suave
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // El icono cambia de color
          Icon(Icons.favorite, color: colorPrincipal, size: 20),
          const SizedBox(width: 6),
          
          // El número de corazones cambia de color
          Text(
            _corazones.toString(),
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: colorPrincipal
            ),
          ),
          
          if (_corazones < VidasService.maxCorazones) ...[
            const SizedBox(width: 8),
            // El cronómetro también cambia de color
            Text(
              "$minutos:$segundos",
              style: TextStyle(
                fontSize: 13, 
                color: colorPrincipal.withValues(alpha: 0.8), 
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ]
        ],
      ),
    );
  }
}