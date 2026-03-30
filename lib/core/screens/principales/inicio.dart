import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/bars/inicio_appbar.dart';
import 'package:tepetl/core/widgets/bars/bottom_nav.dart';
import 'package:tepetl/core/widgets/cards/curso_card.dart';
import 'package:tepetl/core/widgets/cards/recomendacion_card.dart';
import 'package:tepetl/core/widgets/usuario/progreso_map.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int selectedCurso = 0;
  int currentIndex = 2;
  final double progresoMeta = 5 / 10;

  //DATOS
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
      {"label": "VIENTO Y LLUVIA", "icon": Icons.air_outlined, "color": AppColors.textoSecundario40, "active": true, "current": true},
      {"label": "COSMOS", "icon": Icons.nights_stay_outlined, "color": AppColors.secundario, "active": true, "current": false },
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
      appBar: InicioAppBar(isDark: isDark),
      bottomNavigationBar: BottomNav(
        isDark: isDark,
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          return isWide
              ? _desktopBody(constraints, isDark, cs)
              : _mobileBody(constraints, isDark, cs);
        },
      ),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ProgresoMapWidget(
              key: ValueKey(selectedCurso),
              items: progresoPorCurso[selectedCurso],
              isDark: isDark,
            ),
          ),
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.menu_book_outlined, "MIS CURSOS", isDark),
                SizedBox(height: vw * 0.012),
                _cursosRow(vw: vw, isDark: isDark),
                SizedBox(height: vw * 0.022),
                _sectionTitle(Icons.show_chart_outlined, "TU PROGRESO", isDark),
                Center(
                  child: SizedBox(
                    width: rightW,
                    child: Column(
                      children: [
                        SizedBox(height: vw * 0.018),
                        Center(child:
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: ProgresoMapWidget(
                              key: ValueKey(selectedCurso),
                              items: progresoPorCurso[selectedCurso],
                              isDark: isDark,
                            ),
                          )
                        ),
                      ],
                    ),
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
            color: Colors.black.withValues(alpha: 0.3),
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
      children: List.generate(cursos.length, (i) {
        return Expanded(
          child: CursoCard(
            curso: cursos[i],
            isDark: isDark,
            selected: i == selectedCurso,
            onTap: () => setState(() => selectedCurso = i),
          ),
        );
      }),
    );
  }

  Widget _recsRowMobile({required double vw, required bool isDark}) {
    return Row(
      children: List.generate(recomendaciones.length, (i) {
        return Expanded(
          child: RecomendacionCard(
            rec: recomendaciones[i],
            isDark: isDark,
          ),
        );
      }),
    );
  }

  Widget _recsRowDesktop(bool isDark) {
    return Column(
      children: List.generate(recomendaciones.length, (i) {
        return RecomendacionCard(
          rec: recomendaciones[i],
          isDark: isDark,
          horizontal: true,
        );
      }),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 2,
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.3),
          offset: const Offset(4, 4),
        )
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.textoClaro : AppColors.textoSecundario),
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
}