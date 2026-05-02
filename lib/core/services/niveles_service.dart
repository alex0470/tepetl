import 'package:flutter/material.dart';

class NivelXP {
  final int nivel;
  final String nombre;
  final int xpMin;
  final int xpMax;
  final IconData icono;
  final Color color;

  NivelXP({
    required this.nivel,
    required this.nombre,
    required this.xpMin,
    required this.xpMax,
    required this.icono,
    required this.color,
  });
}

class NivelesService {
  static List<NivelXP> niveles = [
    NivelXP(
      nivel: 1,
      nombre: 'Aprendiz',
      xpMin: 0,
      xpMax: 100,
      icono: Icons.school_outlined,
      color: Color(0xFF64B5F6),
    ),
    NivelXP(
      nivel: 2,
      nombre: 'Guerrero',
      xpMin: 100,
      xpMax: 250,
      icono: Icons.shield_outlined,
      color: Color(0xFFEF5350),
    ),
    NivelXP(
      nivel: 3,
      nombre: 'Chamán',
      xpMin: 250,
      xpMax: 450,
      icono: Icons.nights_stay_outlined,
      color: Color(0xFF9C27B0),
    ),
    NivelXP(
      nivel: 4,
      nombre: 'Sacerdote',
      xpMin: 450,
      xpMax: 700,
      icono: Icons.temple_buddhist_outlined,
      color: Color(0xFFFBC02D),
    ),
    NivelXP(
      nivel: 5,
      nombre: 'Señor Jaguar',
      xpMin: 700,
      xpMax: 1000,
      icono: Icons.pets_outlined,
      color: Color(0xFF8D6E63),
    ),
    NivelXP(
      nivel: 6,
      nombre: 'Guardián del Fuego',
      xpMin: 1000,
      xpMax: 1350,
      icono: Icons.local_fire_department_outlined,
      color: Color(0xFFFF6F00),
    ),
    NivelXP(
      nivel: 7,
      nombre: 'Tejedor de Historias',
      xpMin: 1350,
      xpMax: 1750,
      icono: Icons.menu_book_outlined,
      color: Color(0xFF1976D2),
    ),
    NivelXP(
      nivel: 8,
      nombre: 'Guardián del Agua',
      xpMin: 1750,
      xpMax: 2200,
      icono: Icons.water_drop_outlined,
      color: Color(0xFF00897B),
    ),
    NivelXP(
      nivel: 9,
      nombre: 'Señor del Viento',
      xpMin: 2200,
      xpMax: 2700,
      icono: Icons.air_outlined,
      color: Color(0xFF0288D1),
    ),
    NivelXP(
      nivel: 10,
      nombre: 'Guardián de la Tierra',
      xpMin: 2700,
      xpMax: 3250,
      icono: Icons.terrain_outlined,
      color: Color(0xFF558B2F),
    ),
    NivelXP(
      nivel: 11,
      nombre: 'Maestro Nahuatl',
      xpMin: 3250,
      xpMax: 3850,
      icono: Icons.translate_outlined,
      color: Color(0xFFD32F2F),
    ),
    NivelXP(
      nivel: 12,
      nombre: 'Consejero Sabio',
      xpMin: 3850,
      xpMax: 4500,
      icono: Icons.lightbulb_outlined,
      color: Color(0xFFFBC02D),
    ),
    NivelXP(
      nivel: 13,
      nombre: 'Contador de Tiempo',
      xpMin: 4500,
      xpMax: 5200,
      icono: Icons.hourglass_empty_outlined,
      color: Color(0xFF455A64),
    ),
    NivelXP(
      nivel: 14,
      nombre: 'Navegador Cósmico',
      xpMin: 5200,
      xpMax: 5950,
      icono: Icons.auto_awesome_outlined,
      color: Color(0xFF7B1FA2),
    ),
    NivelXP(
      nivel: 15,
      nombre: 'Sembrador de Sabiduría',
      xpMin: 5950,
      xpMax: 6750,
      icono: Icons.eco_outlined,
      color: Color(0xFF2E7D32),
    ),
    NivelXP(
      nivel: 16,
      nombre: 'Guardián del Conocimiento',
      xpMin: 6750,
      xpMax: 7600,
      icono: Icons.library_books_outlined,
      color: Color(0xFF1565C0),
    ),
    NivelXP(
      nivel: 17,
      nombre: 'Maestro de Ceremonias',
      xpMin: 7600,
      xpMax: 8500,
      icono: Icons.celebration_outlined,
      color: Color(0xFFE91E63),
    ),
    NivelXP(
      nivel: 18,
      nombre: 'Portador de Legado',
      xpMin: 8500,
      xpMax: 9500,
      icono: Icons.emoji_events_outlined,
      color: Color(0xFFFFA000),
    ),
    NivelXP(
      nivel: 19,
      nombre: 'Anciano Visionario',
      xpMin: 9500,
      xpMax: 10500,
      icono: Icons.supervised_user_circle_outlined,
      color: Color(0xFF4527A0),
    ),
    NivelXP(
      nivel: 20,
      nombre: 'Quetzalcóatl',
      xpMin: 10500,
      xpMax: 99999,
      icono: Icons.flutter_dash_outlined,
      color: Color(0xFFD4AF37),
    ),
  ];

  static NivelXP getNivelByXP(int xp) {
    for (var nivel in niveles) {
      if (xp >= nivel.xpMin && xp < nivel.xpMax) {
        return nivel;
      }
    }
    return niveles.last;
  }

  static int getProgressToNextLevel(int xp) {
    final nivelActual = getNivelByXP(xp);
    final xpEnNivel = xp - nivelActual.xpMin;
    final xpParaSiguiente = nivelActual.xpMax - nivelActual.xpMin;
    return ((xpEnNivel / xpParaSiguiente) * 100).toInt();
  }
}
