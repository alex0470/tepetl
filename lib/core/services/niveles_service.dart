import 'package:flutter/material.dart';

enum NivelCategoria {
  basico,
  basicoPlus,
  intermedio;

  String get nombre {
    switch (this) {
      case basico:     return 'Básico';
      case basicoPlus: return 'Básico+';
      case intermedio: return 'Intermedio';
    }
  }

  Color get color {
    switch (this) {
      case basico:     return const Color(0xFF64B5F6);
      case basicoPlus: return const Color(0xFF4CAF50);
      case intermedio: return const Color(0xFFFF9800);
    }
  }
}

class NivelXP {
  final int nivel;
  final String nombre;
  final int xpMin;
  final int xpMax;
  final IconData icono;
  final Color color;
  final NivelCategoria categoria;

  const NivelXP({
    required this.nivel,
    required this.nombre,
    required this.xpMin,
    required this.xpMax,
    required this.icono,
    required this.color,
    required this.categoria,
  });
}

class NivelesService {
  static const List<NivelXP> niveles = [
    // ── BÁSICO (1–10) ────────────────────────────────────────────────────────
    NivelXP(nivel: 1,  nombre: 'Aprendiz',              xpMin: 0,     xpMax: 100,   icono: Icons.school_outlined,               color: Color(0xFF64B5F6), categoria: NivelCategoria.basico),
    NivelXP(nivel: 2,  nombre: 'Guerrero',               xpMin: 100,   xpMax: 220,   icono: Icons.shield_outlined,               color: Color(0xFFEF5350), categoria: NivelCategoria.basico),
    NivelXP(nivel: 3,  nombre: 'Chamán',                 xpMin: 220,   xpMax: 360,   icono: Icons.nights_stay_outlined,          color: Color(0xFF9C27B0), categoria: NivelCategoria.basico),
    NivelXP(nivel: 4,  nombre: 'Sacerdote',              xpMin: 360,   xpMax: 530,   icono: Icons.temple_buddhist_outlined,      color: Color(0xFFFBC02D), categoria: NivelCategoria.basico),
    NivelXP(nivel: 5,  nombre: 'Señor Jaguar',           xpMin: 530,   xpMax: 730,   icono: Icons.pets,                          color: Color(0xFF8D6E63), categoria: NivelCategoria.basico),
    NivelXP(nivel: 6,  nombre: 'Guardián del Fuego',     xpMin: 730,   xpMax: 970,   icono: Icons.local_fire_department_outlined, color: Color(0xFFFF6F00), categoria: NivelCategoria.basico),
    NivelXP(nivel: 7,  nombre: 'Tejedor de Historias',   xpMin: 970,   xpMax: 1250,  icono: Icons.menu_book_outlined,            color: Color(0xFF1976D2), categoria: NivelCategoria.basico),
    NivelXP(nivel: 8,  nombre: 'Guardián del Agua',      xpMin: 1250,  xpMax: 1580,  icono: Icons.water_drop_outlined,           color: Color(0xFF00897B), categoria: NivelCategoria.basico),
    NivelXP(nivel: 9,  nombre: 'Señor del Viento',       xpMin: 1580,  xpMax: 1960,  icono: Icons.air_outlined,                  color: Color(0xFF0288D1), categoria: NivelCategoria.basico),
    NivelXP(nivel: 10, nombre: 'Guardián de la Tierra',  xpMin: 1960,  xpMax: 2400,  icono: Icons.terrain_outlined,              color: Color(0xFF558B2F), categoria: NivelCategoria.basico),

    // ── BÁSICO+ (11–20) ──────────────────────────────────────────────────────
    NivelXP(nivel: 11, nombre: 'Maestro Náhuatl',        xpMin: 2400,  xpMax: 2900,  icono: Icons.translate_outlined,            color: Color(0xFFD32F2F), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 12, nombre: 'Consejero Sabio',         xpMin: 2900,  xpMax: 3460,  icono: Icons.lightbulb_outlined,            color: Color(0xFFFBC02D), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 13, nombre: 'Contador de Tiempo',      xpMin: 3460,  xpMax: 4090,  icono: Icons.hourglass_empty_outlined,      color: Color(0xFF455A64), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 14, nombre: 'Navegador Cósmico',       xpMin: 4090,  xpMax: 4790,  icono: Icons.auto_awesome_outlined,         color: Color(0xFF7B1FA2), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 15, nombre: 'Sembrador de Sabiduría',  xpMin: 4790,  xpMax: 5560,  icono: Icons.eco_outlined,                  color: Color(0xFF2E7D32), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 16, nombre: 'Guardián del Conocimiento', xpMin: 5560, xpMax: 6400, icono: Icons.library_books_outlined,         color: Color(0xFF1565C0), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 17, nombre: 'Maestro de Ceremonias',   xpMin: 6400,  xpMax: 7330,  icono: Icons.celebration_outlined,          color: Color(0xFFE91E63), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 18, nombre: 'Portador de Legado',      xpMin: 7330,  xpMax: 8350,  icono: Icons.emoji_events_outlined,         color: Color(0xFFFFA000), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 19, nombre: 'Anciano Visionario',      xpMin: 8350,  xpMax: 9500,  icono: Icons.supervised_user_circle_outlined, color: Color(0xFF4527A0), categoria: NivelCategoria.basicoPlus),
    NivelXP(nivel: 20, nombre: 'Gran Sacerdote',          xpMin: 9500,  xpMax: 10800, icono: Icons.temple_hindu_outlined,         color: Color(0xFFD4AF37), categoria: NivelCategoria.basicoPlus),

    // ── INTERMEDIO (21–30) ───────────────────────────────────────────────────
    NivelXP(nivel: 21, nombre: 'Guardián Celestial',      xpMin: 10800, xpMax: 12200, icono: Icons.brightness_3,                  color: Color(0xFF3949AB), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 22, nombre: 'Señor del Rayo',          xpMin: 12200, xpMax: 13800, icono: Icons.bolt,                          color: Color(0xFFFFD600), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 23, nombre: 'Tejedor del Cosmos',      xpMin: 13800, xpMax: 15600, icono: Icons.workspaces_outlined,           color: Color(0xFF00ACC1), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 24, nombre: 'Portador del Sol',        xpMin: 15600, xpMax: 17600, icono: Icons.wb_sunny_outlined,             color: Color(0xFFFF8F00), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 25, nombre: 'Guardián de la Luna',     xpMin: 17600, xpMax: 19800, icono: Icons.nightlight_outlined,           color: Color(0xFF5C6BC0), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 26, nombre: 'Maestro de los Vientos',  xpMin: 19800, xpMax: 22200, icono: Icons.cyclone,                       color: Color(0xFF00838F), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 27, nombre: 'Custodio del Tiempo',     xpMin: 22200, xpMax: 24800, icono: Icons.access_time_outlined,          color: Color(0xFF546E7A), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 28, nombre: 'Sabio del Universo',      xpMin: 24800, xpMax: 27600, icono: Icons.psychology_outlined,           color: Color(0xFF6A1B9A), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 29, nombre: 'Portador de Quetzal',     xpMin: 27600, xpMax: 30600, icono: Icons.flutter_dash_outlined,         color: Color(0xFF00695C), categoria: NivelCategoria.intermedio),
    NivelXP(nivel: 30, nombre: 'Quetzalcóatl',            xpMin: 30600, xpMax: 999999, icono: Icons.auto_awesome,                 color: Color(0xFFD4AF37), categoria: NivelCategoria.intermedio),
  ];

  static NivelXP getNivelByXP(int xp) {
    for (final nivel in niveles) {
      if (xp >= nivel.xpMin && xp < nivel.xpMax) return nivel;
    }
    return niveles.last;
  }

  static int getProgressToNextLevel(int xp) {
    final n = getNivelByXP(xp);
    final xpEnNivel = xp - n.xpMin;
    final rango = n.xpMax - n.xpMin;
    return ((xpEnNivel / rango) * 100).clamp(0, 100).toInt();
  }

  static List<NivelXP> porCategoria(NivelCategoria cat) =>
      niveles.where((n) => n.categoria == cat).toList();
}
