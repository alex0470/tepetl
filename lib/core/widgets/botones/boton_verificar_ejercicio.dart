import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

/// Botón "Verificar Respuesta" reutilizable.
///
/// - Se habilita solo cuando [enabled] es `true`.
/// - [onPressed] se ejecuta al tocar el botón activo.
/// - [label] permite cambiar el texto (por defecto 'Verificar Respuesta').
class BotonVerificarEjercicio extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final String label;

  const BotonVerificarEjercicio({
    super.key,
    required this.enabled,
    this.onPressed,
    this.label = 'Verificar Respuesta',
  });

  @override
  Widget build(BuildContext context) {
    final double sh = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, sh * 0.03),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
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
                onPressed: enabled ? onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secundario,
                  disabledBackgroundColor:
                      AppColors.secundario.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}