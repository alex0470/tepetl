import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class CursoCard extends StatelessWidget {
  final Map<String, dynamic> curso;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const CursoCard({
    super.key,
    required this.curso,
    required this.isDark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = curso["porcentaje"] as double;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.fondoOscuroSecundario
              : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: AppColors.secundario, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(4, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: isDark
                    ? AppColors.fondoOscuro
                    : AppColors.extra120,
                child: Icon(Icons.image_outlined,
                    size: 36,
                    color: isDark
                        ? AppColors.textoSecundario40
                        : AppColors.textoSecundario20),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badge(curso["nivel"]),
                  const SizedBox(height: 5),

                  Text(
                    curso["titulo"],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: pct,
                              strokeWidth: 3,
                              backgroundColor: isDark
                                  ? AppColors.fondoOscuro
                                  : AppColors.extra120,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppColors.secundario),
                            ),
                            Text(
                              pct >= 1.0
                                  ? "✓"
                                  : "${(pct * 100).toInt()}",
                              style: TextStyle(
                                fontSize: pct >= 1.0 ? 11 : 7,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textoClaro
                                    : AppColors.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pct >= 1.0
                              ? "Completado"
                              : "${(pct * 100).toInt()}% completado",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textoClaro
                                : AppColors.textoSecundario,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String nivel) {
    late Color bg;
    late Color fg;

    switch (nivel) {
      case "ACTUAL":
        bg = AppColors.secundario.withValues(alpha: 0.2);
        fg = AppColors.secundario;
        break;
      case "REPASA":
        bg = AppColors.naranja1.withValues(alpha: 0.2);
        fg = AppColors.naranja1;
        break;
      default:
        bg = AppColors.azul1.withValues(alpha: 0.2);
        fg = AppColors.azul1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        nivel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}