import 'package:flutter/material.dart';
// Asumiendo que AppColors tiene definiciones similares a tu archivo previo
// Si no, puedes reemplazar con Colors.green, Colors.orange, etc.
import 'package:tepetl/core/theme/app_colors.dart';

class AnalisisGeneralContent extends StatelessWidget {
  const AnalisisGeneralContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis General',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Visión general del progreso de Náhuatl',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Grid de KPIs superiores
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: const [
              _TarjetaKPI(
                titulo: 'Usuarios Activos',
                valor: '1.2k',
                cambio: '+12%',
                esPositivo: true,
              ),
              _TarjetaKPI(
                titulo: 'Tasa Completitud',
                valor: '85%',
                cambio: '-2%',
                esPositivo: false,
              ),
              _TarjetaKPI(
                titulo: 'Minutos Práctica',
                valor: '24m',
                cambio: '+5%',
                esPositivo: true,
              ),
              _TarjetaKPI(
                titulo: 'Palabras Nuevas',
                valor: '15',
                cambio: '+20%',
                esPositivo: true,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gráfica de Crecimiento (Placeholder visual)
          _ContenedorGrafica(
            titulo: 'Crecimiento de Usuarios',
            subtitulo: 'Últimos 30 días',
            badge: '+15.4%',
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.green.withOpacity(0.0), Colors.green.withOpacity(0.2)],
                ),
              ),
              child: CustomPaint(painter: _LineChartPainter()),
            ),
          ),
          const SizedBox(height: 24),

          // Distribución por Nivel
          _ContenedorGrafica(
            titulo: 'Distribución por Nivel',
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 0.7,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          color: Colors.greenAccent[700],
                        ),
                      ),
                      const Column(
                        children: [
                          Text('7.4k', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('TOTAL', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LeyendaNivel(color: Colors.green, etiqueta: 'Básico'),
                    _LeyendaNivel(color: Colors.blue, etiqueta: 'Intermedio'),
                    _LeyendaNivel(color: Colors.orange, etiqueta: 'Avanzado'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dificultades Comunes (IA)
          _ContenedorGrafica(
            titulo: 'Dificultades Comunes (IA)',
            icon: Icons.lightbulb_outline,
            child: Column(
              children: [
                _BarraProgresoDificultad(label: 'Pronunciación \'TL\'', valor: 0.82, color: Colors.redAccent, porcentaje: '82%'),
                _BarraProgresoDificultad(label: 'Prefijos de posesión', valor: 0.65, color: Colors.orange, porcentaje: '65%'),
                _BarraProgresoDificultad(label: 'Verbos Transitivos', valor: 0.45, color: Colors.yellow[700]!, porcentaje: '45%'),
                _BarraProgresoDificultad(label: 'Sustantivos Compuestos', valor: 0.20, color: Colors.green, porcentaje: '20%'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('VER INFORME DETALLADO', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Componentes de Apoyo ──────────────────────────────────────────────────────

class _TarjetaKPI extends StatelessWidget {
  final String titulo, valor, cambio;
  final bool esPositivo;

  const _TarjetaKPI({required this.titulo, required this.valor, required this.cambio, required this.esPositivo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(esPositivo ? Icons.trending_up : Icons.trending_down, size: 14, color: esPositivo ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(cambio, style: TextStyle(fontSize: 12, color: esPositivo ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
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

  const _ContenedorGrafica({required this.titulo, this.subtitulo, this.badge, this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: Colors.green, size: 20), const SizedBox(width: 8)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (subtitulo != null) Text(subtitulo!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(badge!, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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

  const _BarraProgresoDificultad({required this.label, required this.valor, required this.color, required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text(porcentaje, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: valor,
            backgroundColor: Colors.grey.withOpacity(0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _LeyendaNivel extends StatelessWidget {
  final Color color;
  final String etiqueta;
  const _LeyendaNivel({required this.color, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(etiqueta, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Simulación simple de la línea de la gráfica
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.4, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.75, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}