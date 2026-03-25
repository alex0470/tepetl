import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ─── LANDING PAGE STUB ─────────────────────────────────────────────────────
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Landing Page")));
}

// ═══════════════════════════════════════════════════════════════════════════
//  INICIO SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int selectedCurso = 0;
  int currentIndex = 2;
  final double progresoMeta = 5 / 10;

  // ── DATOS ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> cursos = [
    {"titulo": "Náhuatl Básico", "nivel": "ACTUAL", "porcentaje": 1.0},
    {"titulo": "Náhuatl Intermedio", "nivel": "NUEVO", "porcentaje": 0.42},
  ];

  final List<Map<String, String>> recomendaciones = [
    {"titulo": "Animales del Bosque", "detalle": "5 min review", "nivel": "REPASA"},
    {"titulo": "Verbos de Movimiento", "detalle": "10 min new lesson", "nivel": "NUEVO"},
  ];

  // Progreso por curso
  final List<List<Map<String, dynamic>>> progresoPorCurso = [
    [
      {"label": "LA CIMA", "icon": Icons.lock_outline, "color": AppColors.textoSecundario40, "active": false, "current": false},
      {"label": "FUEGO Y TIERRA", "icon": Icons.local_fire_department_outlined, "color": AppColors.amarillo1, "active": true, "current": true },
      {"label": "CICLO DEL AGUA", "icon": Icons.water_drop_outlined, "color": AppColors.secundario, "active": true, "current": false},
      {"label": "PLANTAS SAGRADAS", "icon": Icons.eco_outlined, "color": AppColors.secundario, "active": true, "current": false},
      {"label": "LA COMUNIDAD", "icon": Icons.people_outline, "color": AppColors.secundario, "active": true, "current": false},
    ],
    [
      {"label": "LA CIMA", "icon": Icons.lock_outline, "color": AppColors.textoSecundario40, "active": false, "current": false},
      {"label": "VIENTO Y LLUVIA", "icon": Icons.air_outlined, "color": AppColors.textoSecundario40, "active": false, "current": false},
      {"label": "COSMOS", "icon": Icons.nights_stay_outlined, "color": AppColors.secundario, "active": true, "current": true },
      {"label": "TIEMPO SAGRADO", "icon": Icons.hourglass_empty_outlined, "color": AppColors.secundario, "active": true, "current": false},
      {"label": "ORIGEN", "icon": Icons.explore_outlined, "color": AppColors.secundario, "active": true, "current": false},
    ],
  ];

  final List<Map<String, dynamic>> navItems = [
    {"icon": Icons.terrain_outlined, "label": "Cultura"},
    {"icon": Icons.auto_awesome_outlined, "label": "Resumen IA"},
    {"icon": Icons.home_outlined, "label": "Inicio"},
    {"icon": Icons.menu_book_outlined, "label": "Cursos"},
    {"icon": Icons.translate_outlined, "label": "Diccionario"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark, cs),
      bottomNavigationBar: _bottomNav(isDark, cs),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return isWide
              ? _desktopBody(constraints, isDark, cs)
              : _mobileBody(constraints, isDark, cs);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, ColorScheme cs) {
    final bgColor = isDark ? AppColors.fondoOscuro : Colors.white;

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      titleSpacing: 6,
      title: GestureDetector(
        onTap: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const InicioScreen())),
        child: Row(
          mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/logo50.png",
                  width: 28,
                  height: 28,
                ),
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
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 18,
                    // fondoSecundario en light, fondoOscuroSecundario en dark
                    backgroundColor: isDark
                        ? AppColors.fondoOscuroSecundario
                        : AppColors.fondoSecundario,
                    child: Text(
                      "G",
                      style: TextStyle(
                        color: AppColors.primario,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Racha — esquina inferior derecha
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileBody(BoxConstraints c, bool isDark, ColorScheme cs) {
    final vw = c.maxWidth;
    final hp = vw * 0.04;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: hp * 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _metaCard(isDark),
                SizedBox(width: vw * 0.03),
                Expanded(child: _nivelCard()),
              ],
            ),
          ),
          SizedBox(height: vw * 0.055),
          _sectionTitle(Icons.menu_book_outlined, "MIS CURSOS", isDark),
          SizedBox(height: vw * 0.025),
          _cursosRow(vw: vw, isDark: isDark),
          SizedBox(height: vw * 0.055),
          _sectionTitle(Icons.auto_awesome_outlined, "RECOMENDACIONES DE LA IA", isDark),
          SizedBox(height: vw * 0.025),
          _recsRowMobile(vw: vw, isDark: isDark),
          SizedBox(height: vw * 0.065),
          _sectionTitle(Icons.show_chart_outlined, "TU PROGRESO", isDark),
          SizedBox(height: vw * 0.04),
          _progresoMap(isDark),
          SizedBox(height: vw * 0.08),
        ],
      ),
    );
  }

  Widget _desktopBody(BoxConstraints c, bool isDark, ColorScheme cs) {
    final vw = c.maxWidth;
    final gap = vw * 0.025;
    final leftW = vw * 0.27;
    final rightW = vw * 0.22;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: vw * 0.025, vertical: vw * 0.018),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda
          SizedBox(
            width: leftW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _metaCard(isDark),
                      SizedBox(width: vw * 0.015),
                      Expanded(child: _nivelCard()),
                    ],
                  ),
                ),
                SizedBox(height: vw * 0.022),
                _sectionTitle(Icons.auto_awesome_outlined, "RECOMENDACIONES DE LA IA", isDark),
                SizedBox(height: vw * 0.012),
                _recsRowDesktop(isDark),
              ],
            ),
          ),
          SizedBox(width: gap),

          // Columna central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.menu_book_outlined, "MIS CURSOS", isDark),
                SizedBox(height: vw * 0.012),
                _cursosRow(vw: vw, isDark: isDark),

                SizedBox(
                  width: rightW,
                  child: Column(
                    children: [
                      _sectionTitle(Icons.show_chart_outlined, "TU PROGRESO", isDark),
                      SizedBox(height: vw * 0.018),
                      _progresoMap(isDark),
                          ],
                        ),
                ),
              ],
            ),
          ),
          SizedBox(width: gap),

        ],
      ),
    );
  }

  Widget _metaCard(bool isDark) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: _cardDecoration(isDark),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: progresoMeta,
                  strokeWidth: 7,
                  backgroundColor: isDark
                      ? AppColors.fondoOscuroSecundario
                      : AppColors.fondoSecundario,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.secundario),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "5",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    "min",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textoClaro
                          : AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Meta Diaria: 5/10",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.textoClaro
                  : AppColors.textoSecundario,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nivelCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "NIVEL ACTUAL",
            style: TextStyle(
              color: AppColors.textoSecundario20,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Guerrero",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.diamond_outlined, color: AppColors.textoSecundario20, size: 13),
              SizedBox(width: 4),
              Text("+15 jade hoy",
                  style: TextStyle(color: AppColors.textoSecundario20, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cursosRow({required double vw, required bool isDark}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(cursos.length, (i) {
        final c = cursos[i];
        final selected = i == selectedCurso;
        final pct = c["porcentaje"] as double;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedCurso = i),
            child: Container(
              margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
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
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(4, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _badge(c["nivel"] as String),
                        const SizedBox(height: 5),
                        Text(
                          c["titulo"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Círculo de porcentaje
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
                                      color: AppColors.primario,
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
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  RECOMENDACIONES — mobile
  // ═══════════════════════════════════════════════════════════════════════
  Widget _recsRowMobile({required double vw, required bool isDark}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(recomendaciones.length, (i) {
        final r = recomendaciones[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => _popup(r),
            child: Container(
              margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
              decoration: _cardDecoration(isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      color: isDark ? AppColors.fondoOscuro : AppColors.extra120,
                      child: Icon(Icons.image_outlined,
                          size: 28,
                          color: isDark
                              ? AppColors.textoSecundario40
                              : AppColors.textoSecundario20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: _recInfo(r, isDark),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  RECOMENDACIONES — desktop (thumbnail lateral)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _recsRowDesktop(bool isDark) {
    return Column(
      children: List.generate(recomendaciones.length, (i) {
        final r = recomendaciones[i];
        return GestureDetector(
          onTap: () => _popup(r),
          child: Container(
            margin: EdgeInsets.only(bottom: i == 0 ? 8 : 0),
            decoration: _cardDecoration(isDark),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14)),
                  child: Container(
                    width: 58,
                    height: 58,
                    color: isDark ? AppColors.fondoOscuro : AppColors.extra120,
                    child: Icon(Icons.image_outlined,
                        size: 24,
                        color: isDark
                            ? AppColors.textoSecundario40
                            : AppColors.textoSecundario20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _recInfo(r, isDark),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _recInfo(Map<String, String> r, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge(r["nivel"]!),
        const SizedBox(height: 4),
        Text(
          r["titulo"]!,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.access_time_outlined,
                size: 11,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario),
            const SizedBox(width: 3),
            Text(
              r["detalle"]!,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _popup(Map r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(r["titulo"]!),
        content: Text(r["detalle"]!),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar")),
          ElevatedButton(
            onPressed: () {},
            // ElevatedButtonTheme del AppTheme se aplica automáticamente
            child: const Text("Inscribirse"),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  MAPA DE PROGRESO
  // ═══════════════════════════════════════════════════════════════════════
  Widget _progresoMap(bool isDark) {
    final items = progresoPorCurso[selectedCurso];

    return Center(
      child: SizedBox(
        width: 180,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(selectedCurso),
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              final isCurrent = item["current"] as bool;
              final isActive = item["active"] as bool;
              final color = item["color"] as Color;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isCurrent)
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secundario.withOpacity(0.15),
                          ),
                        ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(item["icon"] as IconData,
                            color: Colors.white, size: 24),
                      ),
                      if (isCurrent)
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secundario,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "ESTÁS AQUÍ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item["label"] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? (isDark
                              ? AppColors.textoClaro
                              : AppColors.textoSecundario)
                          : AppColors.textoSecundario40,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _dottedLine(
                        color: isActive
                            ? AppColors.secundario
                            : AppColors.textoSecundario20,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _dottedLine({required Color color}) {
    return SizedBox(
      height: 32,
      child: CustomPaint(
        painter: _DottedLinePainter(color: color),
        size: const Size(2, 32),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  BOTTOM NAV — fijo, usa colores del tema
  // ═══════════════════════════════════════════════════════════════════════
  Widget _bottomNav(bool isDark, ColorScheme cs) {
    final bgColor =
        isDark ? AppColors.fondoOscuro : Colors.white;
    final activeColor = AppColors.primario;
    final inactiveColor =
        isDark ? AppColors.textoSecundario40 : AppColors.textoSecundario40;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (i) {
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => setState(() => currentIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Círculo sólido que flota hacia arriba cuando es activo
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: active
                          ? (Matrix4.identity()..translate(0.0, -6.0))
                          : Matrix4.identity(),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: active ? activeColor : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: AppColors.primario.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Icon(
                        navItems[i]["icon"] as IconData,
                        color: active ? Colors.white : inactiveColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      navItems[i]["label"] as String,
                      style: TextStyle(
                        fontSize: 9,
                        color: active ? activeColor : inactiveColor,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  UTILIDADES
  // ═══════════════════════════════════════════════════════════════════════

  /// Card decoration usando cardColor del tema (fondoSecundario / fondoOscuroSecundario)
  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primario),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color:
                  isDark ? AppColors.textoClaro : AppColors.textoSecundario,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  /// Badge de nivel — usa colores del AppColors
  Widget _badge(String nivel) {
    late Color bg;
    late Color fg;

    switch (nivel) {
      case "ACTUAL":
        bg = AppColors.secundario.withOpacity(0.15);
        fg = AppColors.primario;
        break;
      case "REPASA":
        bg = AppColors.azul1.withOpacity(0.1);
        fg = AppColors.azul1;
        break;
      default: // NUEVO
        bg = AppColors.secundario.withOpacity(0.1);
        fg = AppColors.primario;
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
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTER — línea punteada
// ═══════════════════════════════════════════════════════════════════════════
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const dashH = 5.0;
    const gap = 4.0;
    double y = 0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashH),
        paint,
      );
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter old) =>
      old.color != color;
}