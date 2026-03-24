import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelos de datos de ejemplo
// ─────────────────────────────────────────────────────────────────────────────

class _Curso {
  final String titulo;
  final String nivel;
  final bool completado;
  final bool seleccionado;
  final String imageAsset;
  const _Curso({
    required this.titulo,
    required this.nivel,
    required this.completado,
    required this.imageAsset,
    this.seleccionado = false,
  });
}

class _Recomendacion {
  final String titulo;
  final String etiqueta;
  final String detalle;
  final String imageAsset;
  const _Recomendacion({
    required this.titulo,
    required this.etiqueta,
    required this.detalle,
    required this.imageAsset,
  });
}

class _NivelProgreso {
  final String nombre;
  final bool desbloqueado;
  final bool actual;
  final IconData icono;
  const _NivelProgreso({
    required this.nombre,
    required this.desbloqueado,
    required this.actual,
    required this.icono,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  static const double _kBreakpoint = 700;

  // ── datos mock ──────────────────────────────────────────────────────────────
  static const List<_Curso> _cursos = [
    _Curso(
      titulo: 'Náhuatl Básico',
      nivel: 'ACTUAL',
      completado: true,
      seleccionado: false,
      imageAsset: 'assets/curso_basico.jpg',
    ),
    _Curso(
      titulo: 'Náhuatl Intermedio',
      nivel: 'NUEVO',
      completado: true,
      seleccionado: true,
      imageAsset: 'assets/curso_intermedio.jpg',
    ),
  ];

  static const List<_Recomendacion> _recomendaciones = [
    _Recomendacion(
      titulo: 'Animales del Bosque',
      etiqueta: 'REPASO',
      detalle: '5 min review',
      imageAsset: 'assets/rec_animales.jpg',
    ),
    _Recomendacion(
      titulo: 'Verbos de Movimiento',
      etiqueta: 'NUEVO',
      detalle: '10 min new lesson',
      imageAsset: 'assets/rec_verbos.jpg',
    ),
  ];

  static const List<_NivelProgreso> _niveles = [
    _NivelProgreso(
      nombre: 'LA CIMA',
      desbloqueado: false,
      actual: false,
      icono: Icons.lock_outline,
    ),
    _NivelProgreso(
      nombre: 'FUEGO Y TIERRA',
      desbloqueado: true,
      actual: true,
      icono: Icons.local_fire_department_outlined,
    ),
    _NivelProgreso(
      nombre: 'CICLO DEL AGUA',
      desbloqueado: true,
      actual: false,
      icono: Icons.water_drop_outlined,
    ),
    _NivelProgreso(
      nombre: 'PLANTAS SAGRADAS',
      desbloqueado: true,
      actual: false,
      icono: Icons.eco_outlined,
    ),
    _NivelProgreso(
      nombre: 'LA COMUNIDAD',
      desbloqueado: true,
      actual: false,
      icono: Icons.groups_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mq      = MediaQuery.of(context);
    final double vw = mq.size.width;
    final double vh = mq.size.height;
    final bool isWide = vw >= _kBreakpoint;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isWide
          ? _wideLayout(context, vw: vw, vh: vh)
          : _narrowLayout(context, vw: vw, vh: vh),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LAYOUT ANCHO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _wideLayout(BuildContext context,
      {required double vw, required double vh}) {
    return Column(
      children: [
        // ── barra de navegación superior ─────────────────────────────────
        _TopNavBar(vw: vw, vh: vh),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── columna izquierda ──────────────────────────────────────
              SizedBox(
                width: vw * 0.28,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(vw * 0.015),
                  child: Column(
                    children: [
                      _MetaDiariaCard(vw: vw, vh: vh, isWide: true),
                      SizedBox(height: vh * 0.020),
                      _NivelActualCard(vw: vw, vh: vh, isWide: true),
                      SizedBox(height: vh * 0.020),
                      _RecomendacionesCard(
                        vw: vw,
                        vh: vh,
                        isWide: true,
                        recomendaciones: _recomendaciones,
                      ),
                    ],
                  ),
                ),
              ),

              // ── columna derecha ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(vw * 0.015),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(texto: 'MIS CURSOS', vw: vw),
                      SizedBox(height: vh * 0.012),
                      _CursosGrid(
                          cursos: _cursos, vw: vw, vh: vh, isWide: true),
                      SizedBox(height: vh * 0.030),
                      _SectionLabel(texto: 'TU PROGRESO', vw: vw),
                      SizedBox(height: vh * 0.012),
                      _ProgresoPath(
                          niveles: _niveles, vw: vw, vh: vh, isWide: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LAYOUT ESTRECHO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _narrowLayout(BuildContext context,
      {required double vw, required double vh}) {
    return Column(
      children: [
        // ── app bar compacta ──────────────────────────────────────────────
        _NarrowAppBar(vw: vw, vh: vh),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: vw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: vh * 0.016),

                // meta + nivel en fila
                Row(
                  children: [
                    _MetaDiariaCard(vw: vw, vh: vh, isWide: false),
                    SizedBox(width: vw * 0.03),
                    Expanded(
                      child: _NivelActualCard(vw: vw, vh: vh, isWide: false),
                    ),
                  ],
                ),

                SizedBox(height: vh * 0.022),
                _SectionLabel(texto: '📚 MIS CURSOS', vw: vw),
                SizedBox(height: vh * 0.010),
                _CursosGrid(
                    cursos: _cursos, vw: vw, vh: vh, isWide: false),

                SizedBox(height: vh * 0.022),
                _SectionLabel(texto: '✨ RECOMENDACIONES DE LA IA', vw: vw),
                SizedBox(height: vh * 0.010),
                _RecomendacionesCard(
                  vw: vw,
                  vh: vh,
                  isWide: false,
                  recomendaciones: _recomendaciones,
                ),

                SizedBox(height: vh * 0.022),
                _SectionLabel(texto: 'TU PROGRESO', vw: vw),
                SizedBox(height: vh * 0.010),
                _ProgresoPath(
                    niveles: _niveles, vw: vw, vh: vh, isWide: false),

                SizedBox(height: vh * 0.030),
              ],
            ),
          ),
        ),

        // ── bottom nav bar ────────────────────────────────────────────────
        _BottomNavBar(vw: vw, vh: vh),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP NAV BAR (ancho)
// ─────────────────────────────────────────────────────────────────────────────

class _TopNavBar extends StatelessWidget {
  final double vw, vh;
  const _TopNavBar({required this.vw, required this.vh});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: vh * 0.065,
      color: cs.surface,
      padding: EdgeInsets.symmetric(horizontal: vw * 0.02),
      child: Row(
        children: [
          // logo
          Icon(Icons.terrain, color: AppColors.primario,
              size: (vw * 0.020).clamp(18, 26)),
          SizedBox(width: vw * 0.008),
          Text(
            'TEPETL',
            style: TextStyle(
              color: AppColors.primario,
              fontSize: (vw * 0.016).clamp(13, 20),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          SizedBox(width: vw * 0.03),

          // nav items
          ...[
            ('Inicio', true),
            ('Cultura', false),
            ('Resumen IA', false),
            ('Cursos', false),
            ('Diccionario', false),
          ].map((item) => _NavItem(
                label: item.$1,
                active: item.$2,
                vw: vw,
              )),

          const Spacer(),

          // buscador
          Container(
            width: vw * 0.14,
            height: vh * 0.038,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: vw * 0.01),
            child: Row(
              children: [
                Icon(Icons.search, size: (vw * 0.014).clamp(12, 18),
                    color: cs.onSurfaceVariant),
                SizedBox(width: vw * 0.005),
                Text('Buscar lecciones...',
                    style: TextStyle(
                        fontSize: (vw * 0.010).clamp(9, 13),
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),

          SizedBox(width: vw * 0.015),

          // avatar
          CircleAvatar(
            radius: (vw * 0.015).clamp(14, 22),
            backgroundColor: AppColors.primario,
            child: Text(
              'G',
              style: TextStyle(
                color: Colors.white,
                fontSize: (vw * 0.012).clamp(10, 16),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: vw * 0.006),
          Text(
            'Guerrero',
            style: TextStyle(
              fontSize: (vw * 0.011).clamp(10, 14),
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final double vw;
  const _NavItem(
      {required this.label, required this.active, required this.vw});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: vw * 0.008),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: (vw * 0.011).clamp(10, 14),
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active
                  ? AppColors.primario
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: (vw * 0.03).clamp(20, 40),
              decoration: BoxDecoration(
                color: AppColors.primario,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NARROW APP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _NarrowAppBar extends StatelessWidget {
  final double vw, vh;
  const _NarrowAppBar({required this.vw, required this.vh});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: vh * 0.060,
        padding: EdgeInsets.symmetric(horizontal: vw * 0.04),
        child: Row(
          children: [
            Icon(Icons.terrain,
                color: AppColors.primario,
                size: (vw * 0.055).clamp(20, 32)),
            SizedBox(width: vw * 0.02),
            Text(
              'TEPETL',
              style: TextStyle(
                color: AppColors.primario,
                fontSize: (vw * 0.045).clamp(16, 24),
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              radius: (vw * 0.040).clamp(16, 24),
              backgroundColor: AppColors.primario,
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (vw * 0.035).clamp(13, 18),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// META DIARIA CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MetaDiariaCard extends StatelessWidget {
  final double vw, vh;
  final bool isWide;
  const _MetaDiariaCard(
      {required this.vw, required this.vh, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final double size = isWide
        ? (vw * 0.065).clamp(60, 90)
        : (vw * 0.175).clamp(64, 90);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primario, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '5',
            style: TextStyle(
              fontSize: (size * 0.30).clamp(14, 26),
              fontWeight: FontWeight.w800,
              color: AppColors.primario,
            ),
          ),
          Text(
            'META\nDIARIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: (size * 0.13).clamp(7, 11),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.1,
            ),
          ),
          Text(
            '5/10',
            style: TextStyle(
              fontSize: (size * 0.13).clamp(7, 11),
              color: AppColors.secundario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NIVEL ACTUAL CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NivelActualCard extends StatelessWidget {
  final double vw, vh;
  final bool isWide;
  const _NivelActualCard(
      {required this.vw, required this.vh, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final double cardH = isWide
        ? (vh * 0.14).clamp(100, 140)
        : (vh * 0.11).clamp(80, 110);
    final double titleSize = isWide
        ? (vw * 0.018).clamp(14, 22)
        : (vw * 0.050).clamp(16, 24);
    final double labelSize = isWide
        ? (vw * 0.009).clamp(9, 12)
        : (vw * 0.026).clamp(9, 12);

    return Container(
      height: cardH,
      decoration: BoxDecoration(
        color: AppColors.primario,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: (isWide ? vw * 0.015 : vw * 0.04),
        vertical: vh * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'NIVEL ACTUAL',
            style: TextStyle(
              fontSize: labelSize,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          Text(
            'Guerrero',
            style: TextStyle(
              fontSize: titleSize,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: vw * 0.015, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '✦ +15 Jade hoy',
              style: TextStyle(
                fontSize: labelSize,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECCIÓN LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String texto;
  final double vw;
  const _SectionLabel({required this.texto, required this.vw});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: (vw * 0.030).clamp(11, 16),
        fontWeight: FontWeight.w700,
        color: AppColors.primario,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CURSOS GRID
// ─────────────────────────────────────────────────────────────────────────────

class _CursosGrid extends StatelessWidget {
  final List<_Curso> cursos;
  final double vw, vh;
  final bool isWide;
  const _CursosGrid({
    required this.cursos,
    required this.vw,
    required this.vh,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cursos.map((c) {
        final bool last = cursos.last == c;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: last ? 0 : vw * 0.025),
            child: _CursoCard(
                curso: c, vw: vw, vh: vh, isWide: isWide),
          ),
        );
      }).toList(),
    );
  }
}

class _CursoCard extends StatelessWidget {
  final _Curso curso;
  final double vw, vh;
  final bool isWide;
  const _CursoCard({
    required this.curso,
    required this.vw,
    required this.vh,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final double imgH =
        isWide ? (vh * 0.14).clamp(90, 140) : (vw * 0.28).clamp(80, 120);
    final double titleSize = isWide
        ? (vw * 0.012).clamp(11, 15)
        : (vw * 0.035).clamp(12, 16);
    final double labelSize = isWide
        ? (vw * 0.008).clamp(8, 11)
        : (vw * 0.024).clamp(8, 11);
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: curso.seleccionado
              ? AppColors.secundario
              : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // imagen
          Container(
            height: imgH,
            color: AppColors.primario.withValues(alpha: 0.15),
            child: const Center(
              child: Icon(Icons.image_outlined,
                  color: Colors.white54, size: 36),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(vw * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // etiqueta nivel
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: vw * 0.012, vertical: 2),
                  decoration: BoxDecoration(
                    color: curso.nivel == 'ACTUAL'
                        ? AppColors.secundario.withValues(alpha: 0.15)
                        : AppColors.primario.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    curso.nivel,
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w700,
                      color: curso.nivel == 'ACTUAL'
                          ? AppColors.secundario
                          : AppColors.primario,
                    ),
                  ),
                ),
                SizedBox(height: vh * 0.005),

                Text(
                  curso.titulo,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: vh * 0.006),

                // fila estado
                Row(
                  children: [
                    if (curso.completado)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: vw * 0.010, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primario,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Completado',
                          style: TextStyle(
                            fontSize: labelSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (curso.seleccionado)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: vw * 0.010, vertical: 2),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.secundario),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SELECCIONADO',
                          style: TextStyle(
                            fontSize: labelSize,
                            color: AppColors.secundario,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Text(
                        'SELECCIONAR',
                        style: TextStyle(
                          fontSize: labelSize,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECOMENDACIONES
// ─────────────────────────────────────────────────────────────────────────────

class _RecomendacionesCard extends StatelessWidget {
  final List<_Recomendacion> recomendaciones;
  final double vw, vh;
  final bool isWide;
  const _RecomendacionesCard({
    required this.recomendaciones,
    required this.vw,
    required this.vh,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      // en ancho: lista vertical dentro del panel izquierdo
      return Column(
        children: recomendaciones
            .map((r) => Padding(
                  padding: EdgeInsets.only(bottom: vh * 0.012),
                  child:
                      _RecItem(rec: r, vw: vw, vh: vh, isWide: true),
                ))
            .toList(),
      );
    }
    // en estrecho: dos tarjetas en fila
    return Row(
      children: recomendaciones.map((r) {
        final bool last = recomendaciones.last == r;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: last ? 0 : vw * 0.025),
            child:
                _RecItem(rec: r, vw: vw, vh: vh, isWide: false),
          ),
        );
      }).toList(),
    );
  }
}

class _RecItem extends StatelessWidget {
  final _Recomendacion rec;
  final double vw, vh;
  final bool isWide;
  const _RecItem(
      {required this.rec,
      required this.vw,
      required this.vh,
      required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double imgSize = isWide
        ? (vw * 0.045).clamp(40, 60)
        : (vw * 0.22).clamp(60, 90);
    final double titleSize = isWide
        ? (vw * 0.011).clamp(10, 14)
        : (vw * 0.033).clamp(11, 15);
    final double labelSize = isWide
        ? (vw * 0.009).clamp(8, 11)
        : (vw * 0.026).clamp(8, 11);

    if (isWide) {
      return Row(
        children: [
          Container(
            width: imgSize,
            height: imgSize,
            decoration: BoxDecoration(
              color: AppColors.primario.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image_outlined,
                color: Colors.white54, size: 22),
          ),
          SizedBox(width: vw * 0.012),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EtiquetaChip(
                    texto: rec.etiqueta,
                    labelSize: labelSize),
                SizedBox(height: vh * 0.004),
                Text(
                  rec.titulo,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  rec.detalle,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // estrecho: tarjeta vertical
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imgSize,
            color: AppColors.primario.withValues(alpha: 0.15),
            child: const Center(
              child: Icon(Icons.image_outlined,
                  color: Colors.white54, size: 28),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(vw * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EtiquetaChip(
                    texto: rec.etiqueta,
                    labelSize: labelSize),
                SizedBox(height: vh * 0.004),
                Text(
                  rec.titulo,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  rec.detalle,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaChip extends StatelessWidget {
  final String texto;
  final double labelSize;
  const _EtiquetaChip({required this.texto, required this.labelSize});

  @override
  Widget build(BuildContext context) {
    final bool esRepaso = texto == 'REPASO';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: esRepaso
            ? Colors.orange.withValues(alpha: 0.15)
            : AppColors.primario.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: labelSize,
          fontWeight: FontWeight.w700,
          color: esRepaso ? Colors.orange : AppColors.primario,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESO PATH
// ─────────────────────────────────────────────────────────────────────────────

class _ProgresoPath extends StatelessWidget {
  final List<_NivelProgreso> niveles;
  final double vw, vh;
  final bool isWide;
  const _ProgresoPath({
    required this.niveles,
    required this.vw,
    required this.vh,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final double nodeSize = isWide
        ? (vw * 0.045).clamp(44, 64)
        : (vw * 0.14).clamp(50, 70);
    final double labelSize = isWide
        ? (vw * 0.009).clamp(8, 12)
        : (vw * 0.028).clamp(9, 13);
    final double lineH = isWide
        ? (vh * 0.060).clamp(40, 70)
        : (vh * 0.055).clamp(36, 60);

    // alternancia izq/centro/der para el path
    final List<double> offsets = isWide
        ? [0.0, 0.0, 0.0, 0.0, 0.0]
        : [-vw * 0.10, 0.0, vw * 0.10, 0.0, -vw * 0.10];

    return Column(
      children: List.generate(niveles.length, (i) {
        final n = niveles[i];
        final bool isLast = i == niveles.length - 1;

        return Column(
          children: [
            // nodo
            Transform.translate(
              offset: Offset(offsets[i], 0),
              child: Column(
                children: [
                  // badge "ENTRA AQUÍ" sobre el nodo actual
                  if (n.actual)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secundario,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ENTRA AQUÍ',
                        style: TextStyle(
                          fontSize: labelSize * 0.9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: n.desbloqueado
                          ? (n.actual
                              ? const Color(0xFFE8A020)
                              : AppColors.primario)
                          : Colors.grey.shade300,
                      boxShadow: n.desbloqueado
                          ? [
                              BoxShadow(
                                color: (n.actual
                                        ? const Color(0xFFE8A020)
                                        : AppColors.primario)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      n.icono,
                      color: n.desbloqueado
                          ? Colors.white
                          : Colors.grey.shade500,
                      size: nodeSize * 0.45,
                    ),
                  ),

                  SizedBox(height: vh * 0.006),
                  Text(
                    n.nombre,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: n.actual
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: n.desbloqueado
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // línea punteada entre nodos
            if (!isLast)
              SizedBox(
                height: lineH,
                child: CustomPaint(
                  painter: _DashedLinePainter(
                    color: AppColors.primario.withValues(alpha: 0.4),
                  ),
                  size: Size(2, lineH),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashH = 6;
    const double gapH  = 4;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
          Offset(size.width / 2, y),
          Offset(size.width / 2, (y + dashH).clamp(0, size.height)),
          paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV BAR (estrecho)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final double vw, vh;
  const _BottomNavBar({required this.vw, required this.vh});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (Icons.terrain_outlined,      'Cultura'),
      (Icons.auto_awesome_outlined,  'Resumen IA'),
      (Icons.home_outlined,          'Inicio'),
      (Icons.menu_book_outlined,     'Cursos'),
      (Icons.translate_outlined,     'Diccionario'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: vh * 0.070,
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(color: cs.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final bool active = item.$2 == 'Inicio';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.$1,
                  size: (vw * 0.055).clamp(20, 28),
                  color: active
                      ? AppColors.primario
                      : cs.onSurfaceVariant,
                ),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: (vw * 0.022).clamp(8, 11),
                    color: active
                        ? AppColors.primario
                        : cs.onSurfaceVariant,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}