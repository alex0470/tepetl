import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class RespuestaSheet extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final String correctAnswer;
  final VoidCallback onContinue;
  final String continueLabel;

  const RespuestaSheet({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.correctAnswer,
    required this.onContinue,
    this.continueLabel = 'Continuar',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color accentColor =
        isCorrect ? AppColors.secundario : const Color(0xFFFF4B4B);

    final Color bgBadge = isCorrect
        ? AppColors.secundario.withValues(alpha: 0.2)
        : const Color(0xFFFF4B4B).withValues(alpha: 0.2);

    final Color bodyBg = isDark
        ? AppColors.fondoOscuroSecundario
        : AppColors.fondoSecundario;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgBadge,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.auto_awesome : Icons.close,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isCorrect
                      ? '¡Correcto! Excelente trabajo.'
                      : '¡Casi! Inténtalo de nuevo.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bodyBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 10),
                  Text(
                    'RESPUESTA CORRECTA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '✓  $correctAnswer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secundario,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  continueLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}