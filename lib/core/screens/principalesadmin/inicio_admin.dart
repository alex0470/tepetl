import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class InicioAdminScreen extends StatefulWidget {
  const InicioAdminScreen({super.key});

  @override
  State<InicioAdminScreen> createState() => _InicioAdminScreenState();
}

class _InicioAdminScreenState extends State<InicioAdminScreen> {
  String filtroSeleccionado = 'Todo';

  // Datos de ejemplo para las lecciones
  final List<Map<String, dynamic>> lecciones = [
    {
      'titulo': 'Saludos Básicos (Tlahpaloliztli)',
      'edicion': 'Última edición hace 2 horas',
      'estado': 'Publicado',
      'vistas': '1.2k',
      'likes': '84',
      'icono': Icons.translate,
      'color': Colors.greenAccent,
    },
    {
      'titulo': 'Alimentos (Tlacualli)',
      'edicion': 'Última edición hace 5 horas',
      'estado': 'Borrador',
      'vistas': 'AI Generated',
      'likes': '',
      'icono': Icons.restaurant,
      'color': Colors.orangeAccent,
    },
    {
      'titulo': 'Familiares (Cenyeliztli)',
      'edicion': 'Última edición Ayer',
      'estado': 'Publicado',
      'vistas': '892',
      'likes': '45',
      'icono': Icons.people,
      'color': Colors.blueAccent,
    },
    {
      'titulo': 'Colors (Tlapalli)',
      'edicion': 'Última edición hace 2 días',
      'estado': 'Publicado',
      'vistas': '2.1k',
      'likes': '156',
      'icono': Icons.palette,
      'color': Colors.purpleAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs Superiores
          Row(
            children: [
              const Expanded(
                child: _TarjetaMiniKPI(
                  label: 'LESSONS',
                  valor: '124',
                  cambio: '+12%',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _TarjetaMiniKPI(
                  label: 'ACTIVE',
                  valor: '856',
                  cambio: '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _TarjetaProgresoKPI(
            label: 'COMPLETION RATE',
            valor: '72%',
            progreso: 0.72,
          ),
          const SizedBox(height: 24),

          // Filtros (Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todo', 'Publicado', 'Borradores', 'Archivados']
                  .map((filtro) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: filtroSeleccionado == filtro,
                          selectedColor: AppColors.secundario,
                          labelStyle: TextStyle(
                            color: filtroSeleccionado == filtro ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              filtroSeleccionado = filtro;
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'LECCIONES RECIENTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de Lecciones
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lecciones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = lecciones[index];
              // Lógica de filtrado simple
              if (filtroSeleccionado != 'Todo' && item['estado'] != filtroSeleccionado) {
                if (!(filtroSeleccionado == 'Borradores' && item['estado'] == 'Borrador')) {
                   return const SizedBox.shrink();
                }
              }
              return _LessonCard(item: item, isDark: isDark);
            },
          ),
        ],
      ),
    );
  }
}

// ── Componentes Internos ──────────────────────────────────────────────────────

class _TarjetaMiniKPI extends StatelessWidget {
  final String label, valor, cambio;
  const _TarjetaMiniKPI({required this.label, required this.valor, required this.cambio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(cambio, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaProgresoKPI extends StatelessWidget {
  final String label, valor;
  final double progreso;
  const _TarjetaProgresoKPI({required this.label, required this.valor, required this.progreso});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.secundario,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  const _LessonCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecor(context),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item['icono'], color: item['color']),
            ),
            title: Text(item['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(item['edicion'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Acción: $value sobre ${item['titulo']}')));
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Editar', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Editar')])),
                const PopupMenuItem(value: 'Duplicar', child: Row(children: [Icon(Icons.copy, size: 18), SizedBox(width: 8), Text('Duplicar')])),
                const PopupMenuItem(value: 'Eliminar', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _StatusBadge(estado: item['estado']),
                const Spacer(),
                Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(item['vistas'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (item['likes'].isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.favorite_border, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(item['likes'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String estado;
  const _StatusBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    bool isPublicado = estado == 'Publicado';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPublicado ? Colors.greenAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: isPublicado ? Colors.green : Colors.blue),
          const SizedBox(width: 6),
          Text(
            estado,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPublicado ? Colors.green[700] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _boxDecor(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 2,
        offset: const Offset(3, 3),
      )
    ],
  );
}