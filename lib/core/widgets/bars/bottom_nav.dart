import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final Function(int) onTap;
  final bool isAdmin;

  const BottomNav({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.onTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.fondoOscuro : Colors.white;
    final activeColor = AppColors.secundario;
    final inactiveColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85);

    //Último ítem cambia según el rol
    final lastItem = isAdmin
        ? {"icon": Icons.people_outline, "label": "Usuarios"}
        : {"icon": Icons.translate_outlined, "label": "Diccionario"};

    final navItems = [
      {"icon": Icons.nature_people_outlined, "label": "Cultura"},
      {"icon": Icons.auto_awesome_outlined, "label": "Resumen IA"},
      {"icon": Icons.home_outlined, "label": "Inicio"},
      {"icon": Icons.menu_book_outlined, "label": "Cursos"},
      lastItem,
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (i) {
          final active = i == currentIndex;

          return GestureDetector(
            onTap: () => onTap(i),
            child: Transform.translate(
              offset: Offset(0, active ? -12 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(active ? 12 : 0),
                    decoration: BoxDecoration(
                      color: active ? activeColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      navItems[i]["icon"] as IconData,
                      size: active ? 28 : 22,
                      color: active ? Colors.white : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    navItems[i]["label"] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? activeColor : inactiveColor,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}