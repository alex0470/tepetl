import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/screens/principales/inicio.dart';

class InicioAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;

  const InicioAppBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.fondoOscuro : Colors.white;

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      titleSpacing: 6,
      title: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/logo50.png", width: 28, height: 28),
            const SizedBox(width: 10),
            const Text(
              "TEPETL",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primario,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? AppColors.fondoOscuroSecundario
                    : AppColors.fondoSecundario,
                child: const Text(
                  "G",
                  style: TextStyle(
                    color: AppColors.primario,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.naranja1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}