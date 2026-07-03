import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

/// Widget compartido que muestra la foto de perfil del usuario.
/// Si [fotoUrl] está vacío o falla, muestra las iniciales sobre el color de fondo.
class ProfileAvatar extends StatelessWidget {
  final String fotoUrl;
  final String inicial;
  final double radius;
  final bool isDark;

  const ProfileAvatar({
    super.key,
    required this.fotoUrl,
    required this.inicial,
    this.radius = 20,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (fotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor:
            isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        backgroundImage: NetworkImage(fotoUrl),
        onBackgroundImageError: (_, _) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          inicial.isEmpty ? 'U' : inicial,
          style: TextStyle(
            color: AppColors.primario,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.75,
          ),
        ),
      ),
    );
  }
}
