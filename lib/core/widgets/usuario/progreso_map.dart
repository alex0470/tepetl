import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/leccion_ejercicios_screen.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class ProgresoMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isDark;
  final String? cursoId;
  final String? cursoTitulo;
  final String cursoImagenUrl;

  const ProgresoMapWidget({
    super.key,
    required this.items,
    required this.isDark,
    this.cursoId,
    this.cursoTitulo,
    this.cursoImagenUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    // Agrupar por moduloId manteniendo orden de aparición
    final groups = <String, List<Map<String, dynamic>>>{};
    final groupOrder = <String>[];

    for (final item in items) {
      final moduloId = item['moduloId'] as String? ?? '';
      if (!groups.containsKey(moduloId)) {
        groups[moduloId] = [];
        groupOrder.add(moduloId);
      }
      groups[moduloId]!.add(item);
    }

    final nodes = <Widget>[];

    for (var gi = 0; gi < groupOrder.length; gi++) {
      final moduloId = groupOrder[gi];
      final moduloItems = groups[moduloId]!;
      final moduloName = moduloItems.first['modulo'] as String? ?? '';
      final isLastGroup = gi == groupOrder.length - 1;

      // Línea punteada de separación entre módulos (excepto antes del primero)
      if (gi > 0) {
        nodes.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _dottedLine(color: AppColors.textoSecundario20),
        ));
      }

      // Encabezado del módulo
      nodes.add(_moduloHeader(moduloName, gi));
      nodes.add(const SizedBox(height: 10));

      for (var i = 0; i < moduloItems.length; i++) {
        final item = moduloItems[i];
        final isLastInGroup = i == moduloItems.length - 1;

        nodes.add(GestureDetector(
          onTap: item["active"] == true ? () => _showPopup(context, item) : null,
          child: _node(item),
        ));
        nodes.add(const SizedBox(height: 5));
        nodes.add(Text(
          item["leccion"] ?? item["label"],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: item["active"] == true
                ? (isDark ? AppColors.textoClaro : AppColors.textoSecundario)
                : AppColors.textoSecundario40,
          ),
        ));

        // Línea punteada entre lecciones del mismo módulo
        if (!isLastInGroup) {
          nodes.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _dottedLine(
              color: item["active"] == true
                  ? AppColors.secundario
                  : AppColors.textoSecundario20,
            ),
          ));
        } else if (!isLastGroup) {
          nodes.add(const SizedBox(height: 10));
        }
      }
    }

    return Center(
      child: SizedBox(
        width: 180,
        child: Column(children: nodes),
      ),
    );
  }

  Widget _moduloHeader(String titulo, int index) {
    final colors = [
      AppColors.secundario,
      AppColors.azul1,
      AppColors.naranja1,
      AppColors.amarillo1,
    ];
    final color = colors[index % colors.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 12, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(Map<String, dynamic> item) {
    final isCurrent = item["current"] as bool;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isCurrent)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secundario.withValues(alpha: 0.2),
            ),
          ),

        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColor(item),
          ),
          child: Icon(
            item["icon"],
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getColor(Map<String, dynamic> item) {
    final isActive = item["active"] as bool;
    final isCurrent = item["current"] as bool;
    final isCompleted = item["completada"] == true;

    if (!isActive) return AppColors.textoSecundario40;
    if (isCompleted && !isCurrent) return AppColors.secundario;
    if (isCurrent) return AppColors.amarillo1;
    return item["color"];
  }

  void _showPopup(BuildContext context, Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    String actionText = "Iniciar";
    if (item["current"] == true) {
      actionText = "Continuar";
    } else if (item["active"] == true) {
      actionText = "Repetir";
    }

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor:
              isDark ? AppColors.fondoOscuroSecundario : Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 520 : double.infinity,
            ),
            child: isWide
                ? _popupHorizontal(context, item, actionText)
                : _popupVertical(context, item, actionText),
          ),
        );
      },
    );
  }

  Widget _popupVertical(
      BuildContext context, Map<String, dynamic> item, String actionText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _popupImage(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _popupContent(context, item, actionText),
        ),
      ],
    );
  }

  Widget _popupHorizontal(
      BuildContext context, Map<String, dynamic> item, String actionText) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _popupImage(width: 180, height: 240),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _popupContent(context, item, actionText),
          ),
        ),
      ],
    );
  }

  Widget _popupImage({double width = double.infinity, double height = 160}) {
    final radius = width == double.infinity
        ? const BorderRadius.vertical(top: Radius.circular(20))
        : const BorderRadius.horizontal(left: Radius.circular(20));

    Widget placeholder() => Container(
          width: width,
          height: height,
          color: isDark ? AppColors.fondoOscuro : AppColors.extra120,
          child: Icon(
            Icons.auto_awesome,
            size: 50,
            color: isDark
                ? AppColors.textoSecundario40
                : AppColors.textoSecundario20,
          ),
        );

    return ClipRRect(
      borderRadius: radius,
      child: cursoImagenUrl.isEmpty
          ? placeholder()
          : Image.network(
              cursoImagenUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : placeholder(),
              errorBuilder: (_, _, _) => placeholder(),
            ),
    );
  }

  Widget _popupContent(
      BuildContext context, Map<String, dynamic> item, String actionText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item["leccion"] ?? item["label"],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (item["modulo"] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item["modulo"],
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario,
              ),
            ),
          ),

        const SizedBox(height: 10),

        Builder(builder: (_) {
          final desc = item["descripcion"] as String? ?? '';
          return Text(
            desc.isNotEmpty
                ? desc
                : "Domina esta lección a través de ejercicios interactivos, práctica guiada "
                    "y ejemplos dinámicos diseñados para mejorar tu comprensión progresivamente.",
            style: const TextStyle(fontSize: 13, height: 1.4),
          );
        }),

        const SizedBox(height: 15),

        Builder(builder: (_) {
          final count = (item["ejerciciosIds"] as List?)?.length ?? 0;
          final minutos = count > 0 ? count * 2 : 5;
          final xpMax = count > 0 ? count * 10 : 50;
          return Row(
            children: [
              const Icon(Icons.star_outline, size: 16),
              const SizedBox(width: 4),
              Text("hasta $xpMax XP"),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text("~$minutos min"),
            ],
          );
        }),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _navegarALeccion(context, item),
                  child: Text(
                    actionText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navegarALeccion(BuildContext context, Map<String, dynamic> item) {
    Navigator.of(context).pop();

    if (cursoId == null || item['id'] == null) {
      debugPrint('ProgresoMap: faltan cursoId o item["id"] para navegar.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LeccionEjerciciosScreen(
          cursoId: cursoId!,
          leccionId: item['id'] as String,
          moduloId: item['moduloId'] as String?,
          leccionTitulo: (item['leccion'] ?? item['label']) as String,
          ejerciciosIds: List<String>.from(item['ejerciciosIds'] ?? []),
          totalLeccionesCurso: item['totalLeccionesCurso'] as int? ?? 1,
        ),
      ),
    );
  }

  Widget _dottedLine({required Color color}) {
    return SizedBox(
      height: 32,
      child: CustomPaint(
        painter: _DottedLinePainter(color: color),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const dashH = 5.0;
    const gap = 4.0;
    double y = 0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashH),
        paint,
      );
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter old) => old.color != color;
}
