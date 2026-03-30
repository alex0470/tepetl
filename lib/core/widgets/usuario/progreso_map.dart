import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/completar.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class ProgresoMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isDark;

  const ProgresoMapWidget({
    super.key,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;

            return Column(
              children: [
                GestureDetector(
                  onTap: item["active"]
                      ? () => _showPopup(context, item)
                      : null,
                  child: _node(item),
                ),

                const SizedBox(height: 5),

                Text(
                  item["label"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: item["active"]
                        ? (isDark
                            ? AppColors.textoClaro
                            : AppColors.textoSecundario)
                        : AppColors.textoSecundario40,
                  ),
                ),

                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _dottedLine(
                      color: item["active"]
                          ? AppColors.secundario
                          : AppColors.textoSecundario20,
                    ),
                  ),
              ],
            );
          }),
        ),
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

    if (!isActive) return AppColors.textoSecundario40;
    if (isCurrent) return AppColors.amarillo1;
    return item["color"];
  }

  void _showPopup(BuildContext context, Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    String actionText = "Iniciar";

    if (item["current"]) {
      actionText = "Continuar";
    } else if (item["active"]) {
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
    return ClipRRect(
      borderRadius: width == double.infinity
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : const BorderRadius.horizontal(left: Radius.circular(20)),
      child: Container(
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
          item["label"],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Domina esta lección a través de ejercicios interactivos, práctica guiada "
          "y ejemplos dinámicos diseñados para mejorar tu comprensión progresivamente.",
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: isDark
                ? AppColors.textoClaro
                : AppColors.textoSecundario,
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: const [
            Icon(Icons.star_outline, size: 16),
            SizedBox(width: 4),
            Text("120 pts"),
            SizedBox(width: 12),
            Icon(Icons.access_time, size: 16),
            SizedBox(width: 4),
            Text("5 min"),
          ],
        ),

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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secundario,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const PlantillaCompletar(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Text(
                  actionText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ],
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
  bool shouldRepaint(covariant _DottedLinePainter old) =>
      old.color != color;
}