import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/services/meta_diaria_service.dart';
import 'package:tepetl/core/services/niveles_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/cards/curso_card.dart';
import 'package:tepetl/core/widgets/usuario/progreso_map.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int selectedCurso = 0;
  int currentIndex = 2;
  int _xpUsuario = 0;
  List<CursoModel> _misCursos = [];
  Map<String, dynamic> _progresoData = {};
  bool _isLoading = true;
  int _minutosHoy = 0;
  int _metaDiaria = 10;
  bool _puedeCambiarMeta = false;
  int _diasParaCambiar = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarDatosFirebase(),
      _cargarMetaDiaria(),
    ]);
  }

  Future<void> _cargarDatosFirebase() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final userData = userDoc.data() ?? {};
      _xpUsuario = userData['xp'] ?? 0;

      _misCursos = await CursosService.streamCursosSuscritos(userId).first;

      _progresoData.clear();
      for (var curso in _misCursos) {
        final modulosSnapshot = await FirebaseFirestore.instance
            .collection('cursos')
            .doc(curso.id)
            .collection('modulos')
            .orderBy('orden')
            .get();

        final modulosData = <String, dynamic>{};
        for (var moduloDoc in modulosSnapshot.docs) {
          final moduloId = moduloDoc.id;
          final leccionesSnapshot = await FirebaseFirestore.instance
              .collection('cursos')
              .doc(curso.id)
              .collection('modulos')
              .doc(moduloId)
              .collection('lecciones')
              .orderBy('orden')
              .get();

          final lecciones = <Map<String, dynamic>>[];
          for (var leccionDoc in leccionesSnapshot.docs) {
            final leccionData = leccionDoc.data();
            lecciones.add({
              'id': leccionDoc.id,
              'moduloId': moduloId,
              'titulo': leccionData['titulo'] ?? '',
              'descripcion': leccionData['descripcion'] ?? '',
              'orden': leccionData['orden'] ?? 0,
              'ejerciciosIds': leccionData['ejercicios_ids'] ?? [],
            });
          }

          modulosData[moduloId] = {
            'titulo': moduloDoc['titulo'] ?? '',
            'orden': moduloDoc['orden'] ?? 0,
            'lecciones': lecciones,
          };
        }

        final progresoDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('progreso_cursos')
            .doc(curso.id)
            .get();

        final progresoInfo = progresoDoc.data() ?? {};
        final leccionesCompletadas = List<String>.from(
            progresoInfo['leccionesCompletadas'] ?? []);
        final porcentaje = (progresoInfo['porcentajeTotal'] as num?)?.toDouble() ?? 0.0;
        final xpHoy = progresoInfo['xpHoy'] as int? ?? 0;

        _progresoData[curso.id] = {
          'modulos': modulosData,
          'leccionesCompletadas': leccionesCompletadas,
          'porcentaje': porcentaje,
          'xpHoy': xpHoy,
        };
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error cargando datos Firebase: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarMetaDiaria() async {
    final minutos = await MetaDiariaService.obtenerMinutosHoy();
    final meta = await MetaDiariaService.obtenerMeta();
    final puede = await MetaDiariaService.puedeCambiarMeta();
    final dias = await MetaDiariaService.diasParaCambiarMeta();

    if (mounted) {
      setState(() {
        _minutosHoy = minutos;
        _metaDiaria = meta;
        _puedeCambiarMeta = puede;
        _diasParaCambiar = dias;
      });
    }
  }

  void refresh() {
    if (mounted) {
      setState(() => _isLoading = true);
      _cargarDatos();
    }
  }

  List<Map<String, dynamic>> _construirProgresoModulos(String cursoId) {
    if (!_progresoData.containsKey(cursoId)) return [];

    final data = _progresoData[cursoId] as Map<String, dynamic>;
    final modulosMap = data['modulos'] as Map<String, dynamic>;
    final completadas = List<String>.from(data['leccionesCompletadas'] ?? []);
    final lecciones = <Map<String, dynamic>>[];

    for (var moduloId in modulosMap.keys) {
      final modulo = modulosMap[moduloId] as Map<String, dynamic>;
      final leccionesModulo = modulo['lecciones'] as List<dynamic>;

      for (var leccion in leccionesModulo) {
        final leccionId = leccion['id'] as String;
        final estaCompletada = completadas.contains(leccionId);

        lecciones.add({
          'id': leccionId,
          'moduloId': leccion['moduloId'],
          'label': '${modulo['titulo']} - ${leccion['titulo']}',
          'modulo': modulo['titulo'],
          'leccion': leccion['titulo'],
          'descripcion': leccion['descripcion'] ?? '',
          'ejerciciosIds': leccion['ejerciciosIds'] ?? [],
          'totalLeccionesCurso': _contarLeccionesCurso(cursoId),
          'icon': estaCompletada ? Icons.check_circle : Icons.menu_book_outlined,
          'color': AppColors.secundario,
          'completada': estaCompletada,
          'active': true,
          'current': false,
        });
      }
    }

    // La lección "current" es la primera NO completada
    final primeraIncompleta = lecciones.indexWhere((l) => l['completada'] != true);
    if (primeraIncompleta >= 0) {
      lecciones[primeraIncompleta]['current'] = true;
    } else if (lecciones.isNotEmpty) {
      lecciones.last['current'] = true; // todas completadas
    }

    return lecciones;
  }

  int _contarLeccionesCurso(String cursoId) {
    final data = _progresoData[cursoId] as Map<String, dynamic>?;
    if (data == null) return 1;
    final modulosMap = data['modulos'] as Map<String, dynamic>? ?? {};
    int total = 0;
    for (var m in modulosMap.values) {
      total += ((m as Map)['lecciones'] as List).length;
    }
    return total.clamp(1, 9999);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_misCursos.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined, size: 64, color: AppColors.textoSecundario40),
              const SizedBox(height: 16),
              const Text(
                'No tienes cursos inscritos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inscríbete en cursos para comenzar tu aprendizaje',
                style: TextStyle(color: AppColors.textoSecundario40),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1100;
          return isWide
              ? _desktopBody(constraints, isDark)
              : _mobileBody(constraints, isDark);
        },
      ),
    );
  }

  Widget _mobileBody(BoxConstraints c, bool isDark) {
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
          _sectionTitle(Icons.show_chart_outlined, "TU PROGRESO", isDark),
          SizedBox(height: vw * 0.04),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ProgresoMapWidget(
              key: ValueKey(selectedCurso),
              items: _construirProgresoModulos(_misCursos[selectedCurso].id),
              isDark: isDark,
              cursoId: _misCursos[selectedCurso].id,
              cursoTitulo: _misCursos[selectedCurso].titulo,
              cursoImagenUrl: _misCursos[selectedCurso].imagenUrl,
            ),
          ),
          SizedBox(height: vw * 0.08),
        ],
      ),
    );
  }

  Widget _desktopBody(BoxConstraints c, bool isDark) {
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
                _sectionTitle(
                    Icons.show_chart_outlined, "TU PROGRESO", isDark),
                Center(
                  child: SizedBox(
                    width: rightW,
                    child: Column(
                      children: [
                        SizedBox(height: vw * 0.018),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: ProgresoMapWidget(
                            key: ValueKey(selectedCurso),
                            items: _construirProgresoModulos(
                                _misCursos[selectedCurso].id),
                            isDark: isDark,
                            cursoId: _misCursos[selectedCurso].id,
                            cursoTitulo: _misCursos[selectedCurso].titulo,
                          ),
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
    final progreso = _metaDiaria > 0
        ? (_minutosHoy / _metaDiaria).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: _puedeCambiarMeta
          ? () => _mostrarDialogoCambiarMeta(context, _metaDiaria)
          : null,
      child: Container(
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
                    value: progreso,
                    strokeWidth: 7,
                    backgroundColor: isDark
                        ? AppColors.fondoOscuroSecundario
                        : AppColors.fondoSecundario,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secundario,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$_minutosHoy",
                      style: const TextStyle(
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
              "Meta: $_minutosHoy/$_metaDiaria min",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            if (_puedeCambiarMeta)
              Text(
                "Toca para cambiar",
                style: const TextStyle(fontSize: 9, color: AppColors.secundario),
              )
            else
              Text(
                "Cambia en $_diasParaCambiar días",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? AppColors.textoSecundario40
                        : AppColors.textoSecundario),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoCambiarMeta(
      BuildContext context, int metaActual) async {
    int nuevaMeta = metaActual;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Meta Diaria de Estudio"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Minutos por día: $nuevaMeta",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: nuevaMeta.toDouble(),
                min: 5,
                max: 60,
                divisions: 11,
                label: "$nuevaMeta min",
                onChanged: (val) =>
                    setDialogState(() => nuevaMeta = val.toInt()),
              ),
              Text(
                "Solo podrás cambiarla una vez por semana.",
                style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario40),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final guardado =
                    await MetaDiariaService.cambiarMeta(nuevaMeta);
                if (guardado && mounted) {
                  setState(() {
                    _metaDiaria = nuevaMeta;
                    _puedeCambiarMeta = false;
                    _diasParaCambiar = 7;
                  });
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nivelCard() {
    final nivelActual = NivelesService.getNivelByXP(_xpUsuario);
    int _xpHoy = 0;
    for (var curso in _misCursos) {
      _xpHoy += (_progresoData[curso.id]?['xpHoy'] as int? ?? 0);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: nivelActual.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
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
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nivelActual.nombre,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.diamond_outlined,
                  color: Colors.white.withValues(alpha: 0.7), size: 13),
              const SizedBox(width: 4),
              Text(
                '+$_xpHoy hoy  •  $_xpUsuario XP total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cursosRow({required double vw, required bool isDark}) {
    const double cardH = 200.0;
    final double cardW = (vw * 0.70).clamp(160.0, 240.0);

    return SizedBox(
      height: cardH,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _misCursos.length,
        itemBuilder: (context, i) {
          final curso = _misCursos[i];
          final isSelected = i == selectedCurso;
          final porcentaje = (_progresoData[curso.id] as Map<String, dynamic>?)?['porcentaje'] as double? ?? 0.0;

          return GestureDetector(
            onTap: () => setState(() => selectedCurso = i),
            child: Container(
              width: cardW,
              height: cardH,
              margin: EdgeInsets.only(
                right: i < _misCursos.length - 1 ? 16 : 0,
              ),
              child: CursoCard(
                curso: {
                  "titulo": curso.titulo,
                  "nivel": curso.nivel,
                  "porcentaje": porcentaje,
                  "imagenUrl": curso.imagenUrl,
                },
                isDark: isDark,
                selected: isSelected,
                onTap: () => setState(() => selectedCurso = i),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? AppColors.fondoOscuroSecundario
          : AppColors.fondoSecundario,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 2,
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(3, 3),
        )
      ],
    );
  }
}