import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ── Modelo interno ─────────────────────────────────────────────────────────────

enum _Estado { esperando, verificando, activo, error }

class _Verificacion {
  final _Estado estado;
  final int? latenciaMs;
  final String? mensajeError;
  final DateTime timestamp;

  const _Verificacion({
    required this.estado,
    this.latenciaMs,
    this.mensajeError,
    required this.timestamp,
  });
}

class _EntradaLog {
  final String servicio;
  final String mensaje;
  final DateTime timestamp;

  const _EntradaLog({
    required this.servicio,
    required this.mensaje,
    required this.timestamp,
  });
}

// ── Pantalla principal ─────────────────────────────────────────────────────────

class AnalisisGeneralContent extends StatefulWidget {
  const AnalisisGeneralContent({super.key});

  @override
  State<AnalisisGeneralContent> createState() => _AnalisisGeneralContentState();
}

class _AnalisisGeneralContentState extends State<AnalisisGeneralContent> {
  static const _iaUrl = 'https://bebe-quixotic-stalkily.ngrok-free.dev';

  _Verificacion _bd = _Verificacion(estado: _Estado.esperando, timestamp: DateTime.now());
  _Verificacion _ia = _Verificacion(estado: _Estado.esperando, timestamp: DateTime.now());
  final List<_EntradaLog> _log = [];

  @override
  void initState() {
    super.initState();
    _verificarTodo();
  }

  Future<void> _verificarTodo() async {
    await Future.wait([_verificarBD(), _verificarIA()]);
  }

  Future<void> _verificarBD() async {
    setState(() => _bd = _Verificacion(estado: _Estado.verificando, timestamp: DateTime.now()));
    final sw = Stopwatch()..start();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get(const GetOptions(source: Source.server));
      sw.stop();
      if (!mounted) return;
      setState(() => _bd = _Verificacion(
            estado: _Estado.activo,
            latenciaMs: sw.elapsedMilliseconds,
            timestamp: DateTime.now(),
          ));
    } catch (e) {
      sw.stop();
      final msg = e.toString();
      if (!mounted) return;
      setState(() {
        _bd = _Verificacion(
          estado: _Estado.error,
          latenciaMs: sw.elapsedMilliseconds,
          mensajeError: msg,
          timestamp: DateTime.now(),
        );
        _log.insert(0, _EntradaLog(servicio: 'Firestore', mensaje: msg, timestamp: DateTime.now()));
      });
    }
  }

  Future<void> _verificarIA() async {
    setState(() => _ia = _Verificacion(estado: _Estado.verificando, timestamp: DateTime.now()));
    final sw = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse(_iaUrl), headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 8));
      sw.stop();
      if (!mounted) return;
      final ok = response.statusCode < 500;
      final msg = ok ? null : 'Código de respuesta: ${response.statusCode}';
      setState(() {
        _ia = _Verificacion(
          estado: ok ? _Estado.activo : _Estado.error,
          latenciaMs: sw.elapsedMilliseconds,
          mensajeError: msg,
          timestamp: DateTime.now(),
        );
        if (msg != null) {
          _log.insert(0, _EntradaLog(servicio: 'IA', mensaje: msg, timestamp: DateTime.now()));
        }
      });
    } catch (e) {
      sw.stop();
      final msg = e.toString();
      if (!mounted) return;
      setState(() {
        _ia = _Verificacion(
          estado: _Estado.error,
          latenciaMs: null,
          mensajeError: msg,
          timestamp: DateTime.now(),
        );
        _log.insert(0, _EntradaLog(servicio: 'IA', mensaje: msg, timestamp: DateTime.now()));
      });
    }
  }

  int get _serviciosActivos => [_bd, _ia].where((v) => v.estado == _Estado.activo).length;
  bool get _verificando => _bd.estado == _Estado.verificando || _ia.estado == _Estado.verificando;

  String _latenciaTexto(_Verificacion v) {
    if (v.estado == _Estado.esperando) return '--';
    if (v.estado == _Estado.verificando) return '...';
    if (v.latenciaMs == null) return 'Error';
    return '${v.latenciaMs}ms';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado del Sistema',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Supervisión en tiempo real del backend',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),

          // ── KPIs ────────────────────────────────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _TarjetaKPI(
                titulo: 'Servicios Activos',
                valor: '$_serviciosActivos/2',
                cambio: _serviciosActivos == 2 ? 'Todo OK' : 'Revisar',
                esPositivo: _serviciosActivos == 2,
              ),
              _TarjetaKPI(
                titulo: 'Errores Registrados',
                valor: '${_log.length}',
                cambio: _log.isEmpty ? 'Sin errores' : 'Ver log',
                esPositivo: _log.isEmpty,
              ),
              _TarjetaKPI(
                titulo: 'Latencia BD',
                valor: _latenciaTexto(_bd),
                cambio: _bd.estado == _Estado.activo ? 'Conectado' : _bd.estado == _Estado.verificando ? 'Verificando' : _bd.estado == _Estado.esperando ? 'Pendiente' : 'Sin conexión',
                esPositivo: _bd.estado == _Estado.activo,
              ),
              _TarjetaKPI(
                titulo: 'Latencia IA',
                valor: _latenciaTexto(_ia),
                cambio: _ia.estado == _Estado.activo ? 'Conectado' : _ia.estado == _Estado.verificando ? 'Verificando' : _ia.estado == _Estado.esperando ? 'Pendiente' : 'Sin conexión',
                esPositivo: _ia.estado == _Estado.activo,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Firestore ────────────────────────────────────────────────────────
          _ContenedorGrafica(
            titulo: 'Base de Datos',
            subtitulo: 'Cloud Firestore',
            icon: Icons.storage_outlined,
            child: _TarjetaServicio(
              verificacion: _bd,
              onVerificar: _bd.estado == _Estado.verificando ? null : _verificarBD,
            ),
          ),
          const SizedBox(height: 16),

          // ── Servicio IA ──────────────────────────────────────────────────────
          _ContenedorGrafica(
            titulo: 'Servicio de IA',
            subtitulo: _iaUrl,
            icon: Icons.psychology_outlined,
            child: _TarjetaServicio(
              verificacion: _ia,
              onVerificar: _ia.estado == _Estado.verificando ? null : _verificarIA,
            ),
          ),
          const SizedBox(height: 24),

          // ── Log de errores ───────────────────────────────────────────────────
          _ContenedorGrafica(
            titulo: 'Log de Errores',
            icon: Icons.warning_amber_rounded,
            badge: _log.isEmpty ? null : '${_log.length}',
            child: _log.isEmpty
                ? const _SinErrores()
                : Column(
                    children: [
                      ..._log.take(5).map((e) => _FilaError(entrada: e)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => setState(() => _log.clear()),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('LIMPIAR LOG',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // ── Botón verificar todo ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _verificando ? null : _verificarTodo,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _verificando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.green))
                  : const Text('VERIFICAR TODO',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de estado de servicio ──────────────────────────────────────────────

class _TarjetaServicio extends StatelessWidget {
  final _Verificacion verificacion;
  final VoidCallback? onVerificar;

  const _TarjetaServicio({required this.verificacion, this.onVerificar});

  Color get _color {
    switch (verificacion.estado) {
      case _Estado.activo:
        return Colors.green;
      case _Estado.error:
        return Colors.red;
      case _Estado.verificando:
        return Colors.orange;
      case _Estado.esperando:
        return Colors.grey;
    }
  }

  IconData get _icono {
    switch (verificacion.estado) {
      case _Estado.activo:
        return Icons.check_circle_outline;
      case _Estado.error:
        return Icons.error_outline;
      case _Estado.verificando:
        return Icons.sync;
      case _Estado.esperando:
        return Icons.radio_button_unchecked;
    }
  }

  String get _etiqueta {
    switch (verificacion.estado) {
      case _Estado.activo:
        return 'Conectado';
      case _Estado.error:
        return 'Error';
      case _Estado.verificando:
        return 'Verificando...';
      case _Estado.esperando:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = verificacion.timestamp;
    final hora =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            // Indicador de estado
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: verificacion.estado == _Estado.verificando
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _color),
                    )
                  : Icon(_icono, color: _color, size: 20),
            ),
            const SizedBox(width: 12),

            // Etiqueta y timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_etiqueta,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _color)),
                  Text('Último chequeo: $hora',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),

            // Latencia badge
            if (verificacion.latenciaMs != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${verificacion.latenciaMs}ms',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _color),
                ),
              ),
          ],
        ),

        // Mensaje de error
        if (verificacion.mensajeError != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Text(
              verificacion.mensajeError!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],

        const SizedBox(height: 14),

        // Barra de progreso visual
        _BarraProgresoDificultad(
          label: 'Disponibilidad',
          valor: verificacion.estado == _Estado.activo ? 1.0 : verificacion.estado == _Estado.error ? 0.0 : 0.5,
          color: _color,
          porcentaje: verificacion.estado == _Estado.activo
              ? '100%'
              : verificacion.estado == _Estado.error
                  ? '0%'
                  : '--',
        ),

        // Botón verificar
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onVerificar,
            style: TextButton.styleFrom(
              backgroundColor: _color.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'VERIFICAR CONEXIÓN',
              style: TextStyle(color: _color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Fila del log de errores ────────────────────────────────────────────────────

class _FilaError extends StatelessWidget {
  final _EntradaLog entrada;
  const _FilaError({required this.entrada});

  @override
  Widget build(BuildContext context) {
    final ts = entrada.timestamp;
    final hora =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(entrada.servicio,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                    ),
                    const SizedBox(width: 6),
                    Text(hora,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(entrada.mensaje,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sin errores ────────────────────────────────────────────────────────────────

class _SinErrores extends StatelessWidget {
  const _SinErrores();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              color: Colors.green.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 10),
          const Text('No se han registrado errores.',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Componentes reutilizados (sin cambios) ────────────────────────────────────

class _TarjetaKPI extends StatelessWidget {
  final String titulo, valor, cambio;
  final bool esPositivo;

  const _TarjetaKPI(
      {required this.titulo,
      required this.valor,
      required this.cambio,
      required this.esPositivo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(valor,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(
                  esPositivo ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: esPositivo ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(cambio,
                  style: TextStyle(
                      fontSize: 12,
                      color: esPositivo ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContenedorGrafica extends StatelessWidget {
  final String titulo;
  final String? subtitulo, badge;
  final IconData? icon;
  final Widget child;

  const _ContenedorGrafica(
      {required this.titulo,
      this.subtitulo,
      this.badge,
      this.icon,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.green, size: 20),
                const SizedBox(width: 8)
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (subtitulo != null)
                      Text(subtitulo!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(badge!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BarraProgresoDificultad extends StatelessWidget {
  final String label, porcentaje;
  final double valor;
  final Color color;

  const _BarraProgresoDificultad(
      {required this.label,
      required this.valor,
      required this.color,
      required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 13, color: Colors.grey)),
              Text(porcentaje,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: valor,
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
