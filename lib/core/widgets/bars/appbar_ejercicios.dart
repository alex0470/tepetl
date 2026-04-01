import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

/// AppBar reutilizable para pantallas de lección.
///
/// Muestra:
/// - Botón X (cerrar) a la izquierda → llama a [onClose].
/// - [title] centrado (p. ej. 'EXPRESIÓN ESCRITA').
/// - Contador de corazones a la derecha; se actualiza reactivamente
///   desde el padre vía [hearts].
class AppbarEjercicios extends StatelessWidget {
  final String title;
  final int hearts;
  final VoidCallback onClose;

  const AppbarEjercicios({
    super.key,
    required this.title,
    required this.hearts,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sh * 0.015,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 30),
          ),

          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.secundario,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // ── Corazones ─────────────────────────────────────────────
          _HeartsChip(hearts: hearts),
        ],
      ),
    );
  }
}

// ── Chip de corazones ─────────────────────────────────────────────────────────
class _HeartsChip extends StatelessWidget {
  final int hearts;

  const _HeartsChip({required this.hearts});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: hearts > 0 ? const Color(0xFFFF4B4B) : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              hearts > 0 ? Icons.favorite : Icons.heart_broken,
              key: ValueKey(hearts > 0),
              color: Colors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$hearts',
              key: ValueKey(hearts),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonProgressBar extends StatelessWidget {
  final String lessonLabel;
  final double progress;
  final double progressWidth;
 
  const LessonProgressBar({
    super.key,
    required this.lessonLabel,
    required this.progress,
    required this.progressWidth,
  });
 
  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isWide = sw > 1000;
 
    final String percent = '${(progress * 100).round()}%';
 
    return Center(
      child: SizedBox(
        width: progressWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Etiqueta ──────────────────────────────────────────────
              Text(
                lessonLabel,
                style: const TextStyle(
                  color: AppColors.secundario,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
 
              // ── Barra + porcentaje ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: isWide ? 14 : 12,
                          backgroundColor:
                              AppColors.secundario.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secundario,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      percent,
                      key: ValueKey(percent),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}