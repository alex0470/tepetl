import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/examen_nivel_screen.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/theme/curso_filters.dart';

// ── Sugerencias IA (datos estáticos) ─────────────────────────────────────────

class _Sugerencia {
  final String etiqueta;
  final String titulo;
  final String descripcion;
  final String botonLabel;
  final bool botonOscuro;
  final IconData icono;

  const _Sugerencia({
    required this.etiqueta,
    required this.titulo,
    required this.descripcion,
    required this.botonLabel,
    required this.botonOscuro,
    required this.icono,
  });
}

const List<_Sugerencia> _sugerencias = [
  _Sugerencia(
    etiqueta: 'BASADO EN TU DESEMPEÑO',
    titulo: 'Fortalece tus bases',
    descripcion:
        'Repasa los pronombres posesivos para mejorar tu fluidez en el módulo actual.',
    botonLabel: 'Comenzar Repaso',
    botonOscuro: true,
    icono: Icons.refresh_rounded,
  ),
  _Sugerencia(
    etiqueta: 'SIGUIENTE NIVEL',
    titulo: 'Expande tu vocabulario',
    descripcion:
        'Has dominado los verbos básicos. Es momento de aprender adjetivos de color y textura.',
    botonLabel: 'Ver Nuevos Temas',
    botonOscuro: false,
    icono: Icons.trending_up_rounded,
  ),
];

// ── Pantalla principal ────────────────────────────────────────────────────────

class CursosScreen extends StatelessWidget {
  const CursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 1000;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      body: SafeArea(
        child: isWide
            ? _WideLayout(isDark: isDark)
            : _MobileLayout(isDark: isDark),
      ),
    );
  }
}

// ── Layout Móvil ──────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final bool isDark;
  const _MobileLayout({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SeccionMisCursos(isDark: isDark, isWide: false),
          const SizedBox(height: 24),
          _SeccionSugerencias(isDark: isDark, isWide: false),
          const SizedBox(height: 24),
          _SeccionExplorar(isDark: isDark, isWide: false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Layout Ancho ──────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final bool isDark;
  const _WideLayout({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SeccionMisCursos(isDark: isDark, isWide: true),
                const SizedBox(height: 32),
                _SeccionExplorar(isDark: isDark, isWide: true),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 340,
            child: _SeccionSugerencias(isDark: isDark, isWide: true),
          ),
        ],
      ),
    );
  }
}

// ── Sección: Mis Cursos ───────────────────────────────────────────────────────

class _SeccionMisCursos extends StatelessWidget {
  final bool isDark;
  final bool isWide;

  const _SeccionMisCursos({required this.isDark, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<CursoModel>>(
      stream: CursosService.streamCursosSuscritos(userId),
      builder: (context, snapshot) {
        final cursos = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'MIS CURSOS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secundario.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cursos.length} ACTIVOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secundario,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (cursos.isEmpty)
              _EmptyMisCursos(isDark: isDark)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final double w = constraints.maxWidth;
                  int columns = w > 650 ? 2 : 1;
                  double spacing = 16.0;
                  double itemWidth =
                      (w - (columns - 1) * spacing) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: cursos
                        .map(
                          (curso) => SizedBox(
                            width: itemWidth,
                            child: _TarjetaCurso(
                              curso: curso,
                              isDark: isDark,
                              userId: userId,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _EmptyMisCursos extends StatelessWidget {
  final bool isDark;
  const _EmptyMisCursos({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(
            'Aún no tienes cursos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explora los cursos disponibles abajo e inscríbete.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCurso extends StatelessWidget {
  final CursoModel curso;
  final bool isDark;
  final String userId;

  const _TarjetaCurso({
    required this.curso,
    required this.isDark,
    required this.userId,
  });

  Future<void> _anularInscripcion(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Anular inscripción?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('Se eliminará "${curso.titulo}" de tu lista de cursos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.rojo1),
            child: const Text('Anular',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      // Eliminar el documento de progreso del usuario
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progreso_cursos')
          .doc(curso.id)
          .delete();

      // Restar 1 en suscritos_count (sin bajar de 0)
      final cursoRef = FirebaseFirestore.instance
          .collection('cursos')
          .doc(curso.id);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snap = await transaction.get(cursoRef);
        final currentCount = (snap.data()?['suscritos_count'] ?? 1) as int;
        transaction.update(cursoRef, {
          'suscritos_count': currentCount > 0 ? currentCount - 1 : 0,
        });
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscripción anulada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: _CourseImage(
                    url: curso.imagenUrl,
                    titulo: curso.titulo,
                    height: 60,
                    width: 60,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curso.titulo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      curso.nivel,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secundario,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.60),
                ),
              ),
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.0,
              minHeight: 6,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.20),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.secundario),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _anularInscripcion(context),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined,
                        color: AppColors.rojo1, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'ANULAR INSCRIPCIÓN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rojo1,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sección: Explorar (Oficiales + De usuarios admin) ─────────────────────────

class _SeccionExplorar extends StatefulWidget {
  final bool isDark;
  final bool isWide;

  const _SeccionExplorar({required this.isDark, required this.isWide});

  @override
  State<_SeccionExplorar> createState() => _SeccionExplorarState();
}

class _SeccionExplorarState extends State<_SeccionExplorar> {
  String? _filtroNivel;
  String? _filtroCategoria;
  String? _nivelUsuario;

  // Niveles de curso accesibles por nivel del usuario (acumulativo)
  static const Map<String, List<String>> _nivelesPermitidos = {
    'basico':     ['basico'],
    'basico+':    ['basico', 'basico+'],
    'intermedio': ['basico', 'basico+', 'intermedio'],
    'avanzado':   ['basico', 'basico+', 'intermedio', 'avanzado'],
  };

  @override
  void initState() {
    super.initState();
    _cargarNivelUsuario();
  }

  Future<void> _cargarNivelUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final nivel = (doc.data() ?? {})['nivel_educativo'] as String?;
    if (mounted) setState(() => _nivelUsuario = nivel);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXPLORAR CURSOS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            _BotonFiltros(
              isDark: widget.isDark,
              filtroNivel: _filtroNivel,
              filtroCategoria: _filtroCategoria,
              onNivelChanged: (nivel) {
                setState(() => _filtroNivel = nivel);
              },
              onCategoriaChanged: (categoria) {
                setState(() => _filtroCategoria = categoria);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Cursos Oficiales ────────────────────────────────────────────────
        _SubtituloSeccion(
          icono: Icons.verified_rounded,
          color: AppColors.secundario,
          label: 'Oficiales',
          descripcion: 'Creados y validados por el equipo de Tepetl',
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<CursoModel>>(
          stream: CursosService.streamCursosOficiales(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var cursos = snapshot.data ?? [];
            cursos = _aplicarFiltros(cursos);
            if (cursos.isEmpty) {
              return _EmptyExplorar(
                mensaje: 'No hay cursos que coincidan con los filtros.',
                isDark: widget.isDark,
              );
            }
            return _GridCursos(
              cursos: cursos,
              isDark: widget.isDark,
            );
          },
        ),

        const SizedBox(height: 28),

        // ── Cursos de administradores / comunidad ───────────────────────────
        _SubtituloSeccion(
          icono: Icons.people_alt_rounded,
          color: AppColors.amarillo1,
          label: 'De la comunidad',
          descripcion: 'Creados por instructores y administradores',
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<CursoModel>>(
          stream: CursosService.streamCursosDeUsuarios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var cursos = snapshot.data ?? [];
            cursos = _aplicarFiltros(cursos);
            if (cursos.isEmpty) {
              return _EmptyExplorar(
                mensaje: 'No hay cursos que coincidan con los filtros.',
                isDark: widget.isDark,
              );
            }
            return _GridCursos(
              cursos: cursos,
              isDark: widget.isDark,
            );
          },
        ),
      ],
    );
  }

  List<CursoModel> _aplicarFiltros(List<CursoModel> cursos) {
    final nivelesAccesibles = _nivelUsuario != null
        ? (_nivelesPermitidos[_nivelUsuario] ?? _nivelesPermitidos.values.expand((v) => v).toSet().toList())
        : null;

    return cursos.where((curso) {
      final nivelUsuarioMatch = nivelesAccesibles == null || nivelesAccesibles.contains(curso.nivel);
      final nivelFiltroMatch = _filtroNivel == null || curso.nivel == _filtroNivel;
      final categoriaMatch = _filtroCategoria == null || curso.categoria == _filtroCategoria;
      return nivelUsuarioMatch && nivelFiltroMatch && categoriaMatch;
    }).toList();
  }
}

class _SubtituloSeccion extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String label;
  final String descripcion;

  const _SubtituloSeccion({
    required this.icono,
    required this.color,
    required this.label,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              descripcion,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyExplorar extends StatelessWidget {
  final String mensaje;
  final bool isDark;
  const _EmptyExplorar({required this.mensaje, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        mensaje,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _GridCursos extends StatelessWidget {
  final List<CursoModel> cursos;
  final bool isDark;

  const _GridCursos({required this.cursos, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        int columns = w > 850 ? 3 : (w > 550 ? 2 : 1);
        double spacing = 16.0;
        double itemWidth = (w - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cursos
              .map(
                (curso) => SizedBox(
                  width: itemWidth,
                  child: _TarjetaCursoExplorar(curso: curso, isDark: isDark),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

// ── Widget de imagen de portada ───────────────────────────────────────────────

/// Muestra la imagen de portada del curso.
/// Si la URL está vacía o falla, muestra un placeholder con iniciales.
class _CourseImage extends StatelessWidget {
  final String url;
  final String titulo;
  final double height;
  final double? width;
  final BoxFit fit;

  const _CourseImage({
    required this.url,
    required this.titulo,
    this.height = 140,
    this.width,
    this.fit = BoxFit.cover,
  });

  Color _colorFromTitle() {
    const colors = [
      Color(0xFF2D6A4F),
      Color(0xFF1B4332),
      Color(0xFF40916C),
      Color(0xFF52B788),
      Color(0xFF1D3557),
      Color(0xFF457B9D),
      Color(0xFF6D4C41),
    ];
    return colors[titulo.length % colors.length];
  }

  Widget _placeholder() {
    final color = _colorFromTitle();
    final initials = titulo.isNotEmpty
        ? titulo.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: color,
      child: Center(
        child: Container(
          width: height * 0.37,
          height: height * 0.37,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: height * 0.16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Image.network(
        url,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder();
        },
        errorBuilder: (context, error, stackTrace) {
          // ignore: avoid_print
          print('[_CourseImage] ERROR cargando "$url": $error');
          return _placeholder();
        },
      ),
    );
  }
}

// ── Tarjeta de curso en Explorar (con estado de inscripción) ──────────────────

class _TarjetaCursoExplorar extends StatefulWidget {
  final CursoModel curso;
  final bool isDark;

  const _TarjetaCursoExplorar({required this.curso, required this.isDark});

  @override
  State<_TarjetaCursoExplorar> createState() => _TarjetaCursoExplorarState();
}

class _TarjetaCursoExplorarState extends State<_TarjetaCursoExplorar> {
  bool _inscribiendo = false;

  Future<void> _inscribir(BuildContext context, String userId) async {
    setState(() => _inscribiendo = true);
    try {
      await CursosService.inscribirUsuarioEnCurso(userId, widget.curso.id);

      // Sumar 1 en suscritos_count
      final cursoRef = FirebaseFirestore.instance
          .collection('cursos')
          .doc(widget.curso.id);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snap = await transaction.get(cursoRef);
        final currentCount = (snap.data()?['suscritos_count'] ?? 0) as int;
        transaction.update(cursoRef, {'suscritos_count': currentCount + 1});
      });

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('¡Inscripción exitosa!',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(
                'Te has inscrito a "${widget.curso.titulo}". Ya aparece en Mis Cursos.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inscribiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      // Escucha en tiempo real si el usuario ya está suscrito
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progreso_cursos')
          .doc(widget.curso.id)
          .snapshots(),
      builder: (context, snapshot) {
        final yaSuscrito = snapshot.data?.exists ?? false;

        return Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppColors.fondoOscuroSecundario
                : AppColors.fondoSecundario,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen con badge de nivel
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    _CourseImage(
                      url: widget.curso.imagenUrl,
                      titulo: widget.curso.titulo,
                      height: 140,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.curso.nivel == 'Básico'
                              ? AppColors.secundario.withValues(alpha: 0.8)
                              : AppColors.amarillo1.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.curso.nivel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Badge "Ya inscrito"
                    if (yaSuscrito)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 11, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'INSCRITO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.curso.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.85),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.curso.descripcion,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_outline,
                                size: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.curso.suscritosCount} alumnos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 34,
                          child: yaSuscrito
                              ? OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.green),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(9),
                                    ),
                                  ),
                                  child: const Text(
                                    'Inscrito ✓',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _inscribiendo
                                      ? null
                                      : () => _inscribir(context, userId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secundario,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(9),
                                    ),
                                  ),
                                  child: _inscribiendo
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Inscribirme',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
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
        );
      },
    );
  }
}

// ── Sección: Sugerencias IA ───────────────────────────────────────────────────

class _SeccionSugerencias extends StatelessWidget {
  final bool isDark;
  final bool isWide;
  const _SeccionSugerencias({required this.isDark, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 14, color: AppColors.secundario),
            const SizedBox(width: 6),
            Text(
              'SUGERENCIAS DE LA IA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isWide)
          Column(
            children: _sugerencias
                .map(
                  (s) => Padding(
                    padding: EdgeInsets.only(
                        bottom: s == _sugerencias.last ? 0 : 14),
                    child: _TarjetaSugerencia(
                        sugerencia: s, isDark: isDark, isWide: true),
                  ),
                )
                .toList(),
          )
        else
          SizedBox(
            height: 220,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sugerencias.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: 220,
                  child: _TarjetaSugerencia(
                      sugerencia: _sugerencias[i],
                      isDark: isDark,
                      isWide: false),
                ),
              ),
            ),
          ),
        if (!isWide) ...[
          const SizedBox(height: 16),
          _ForoDelDia(isDark: isDark),
        ],
        if (isWide) ...[
          const SizedBox(height: 14),
          _ForoDelDia(isDark: isDark),
        ],
      ],
    );
  }
}

class _TarjetaSugerencia extends StatelessWidget {
  final _Sugerencia sugerencia;
  final bool isDark;
  final bool isWide;
  const _TarjetaSugerencia(
      {required this.sugerencia, required this.isDark, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      height: 215,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sugerencia.etiqueta,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: sugerencia.botonOscuro
                      ? AppColors.secundario
                      : AppColors.amarillo1,
                ),
              ),
              Icon(
                sugerencia.icono,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.40),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sugerencia.titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sugerencia.descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExamenNivelScreen()),
              ),
              icon: Icon(sugerencia.icono, size: 14),
              label: Text(
                sugerencia.botonLabel,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primario,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Foro del día ──────────────────────────────────────────────────────────────

class _ForoDelDia extends StatelessWidget {
  final bool isDark;
  const _ForoDelDia({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_outlined, size: 14, color: AppColors.secundario),
              const SizedBox(width: 6),
              Text(
                'Foro del día',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textoClaro
                      : AppColors.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"¿Cómo se dice \'pueblo\' en tu variante local?"',
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark ? AppColors.textoClaro : AppColors.textoSecundario,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 24,
                child: Stack(
                  children: List.generate(
                    4,
                    (i) => Positioned(
                      left: i * 16.0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: [
                            AppColors.azul1,
                            AppColors.secundario,
                            AppColors.amarillo1,
                            AppColors.azulAqua,
                          ][i],
                          border: Border.all(
                            color: isDark
                                ? AppColors.fondoOscuroSecundario
                                : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            ['A', 'B', 'C', 'G'][i],
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+12',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secundario,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Botón de Filtros ───────────────────────────────────────────────────────────

class _BotonFiltros extends StatefulWidget {
  final bool isDark;
  final String? filtroNivel;
  final String? filtroCategoria;
  final ValueChanged<String?> onNivelChanged;
  final ValueChanged<String?> onCategoriaChanged;

  const _BotonFiltros({
    required this.isDark,
    this.filtroNivel,
    this.filtroCategoria,
    required this.onNivelChanged,
    required this.onCategoriaChanged,
  });

  @override
  State<_BotonFiltros> createState() => _BotonFiltrosState();
}

class _BotonFiltrosState extends State<_BotonFiltros> {
  late OverlayEntry _overlayEntry;
  bool _isOpen = false;

  void _mostrarFiltros() {
    if (_isOpen) {
      _overlayEntry.remove();
      setState(() => _isOpen = false);
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        const panelMaxHeight = 500.0;
        const gap = 8.0;
        final screenSize = MediaQuery.of(ctx).size;
        final right = screenSize.width - offset.dx - size.width;
        final spaceBelow = screenSize.height - (offset.dy + size.height + gap);
        final openUpward = spaceBelow < panelMaxHeight;

        return Positioned(
          right: right,
          top: openUpward ? null : offset.dy + size.height + gap,
          bottom: openUpward ? screenSize.height - offset.dy + gap : null,
          child: Material(
            color: Colors.transparent,
            child: _PanelFiltros(
              isDark: widget.isDark,
              filtroNivel: widget.filtroNivel,
              filtroCategoria: widget.filtroCategoria,
              onNivelChanged: (nivel) {
                widget.onNivelChanged(nivel);
                setState(() {});
              },
              onCategoriaChanged: (categoria) {
                widget.onCategoriaChanged(categoria);
                setState(() {});
              },
              onClose: () {
                _overlayEntry.remove();
                setState(() => _isOpen = false);
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry);
    setState(() => _isOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    final tieneActivos = widget.filtroNivel != null ||
        widget.filtroCategoria != null;

    return GestureDetector(
      onTap: _mostrarFiltros,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tieneActivos
              ? AppColors.secundario.withValues(alpha: 0.15)
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: tieneActivos
                ? AppColors.secundario
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: tieneActivos
                  ? AppColors.secundario
                  : Theme.of(context).colorScheme.onSurface,
            ),
            if (tieneActivos)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.secundario,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Panel de Filtros ───────────────────────────────────────────────────────────

class _PanelFiltros extends StatelessWidget {
  final bool isDark;
  final String? filtroNivel;
  final String? filtroCategoria;
  final ValueChanged<String?> onNivelChanged;
  final ValueChanged<String?> onCategoriaChanged;
  final VoidCallback onClose;

  const _PanelFiltros({
    required this.isDark,
    this.filtroNivel,
    this.filtroCategoria,
    required this.onNivelChanged,
    required this.onCategoriaChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FILTROS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'NIVEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...CursoFilters.niveles.map((nivel) {
                    final isSelected = filtroNivel == nivel;
                    return GestureDetector(
                      onTap: () {
                        onNivelChanged(isSelected ? null : nivel);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secundario.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secundario
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secundario
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppColors.secundario,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              nivel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.secundario
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'CATEGORÍA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...CursoFilters.categorias.map((categoria) {
                    final isSelected = filtroCategoria == categoria;
                    final icono = CursoFilters.getCategoryIcon(categoria);
                    final color = CursoFilters.getCategoryColor(categoria);
                    return GestureDetector(
                      onTap: () {
                        onCategoriaChanged(isSelected ? null : categoria);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Icon(icono, size: 16, color: color),
                            const SizedBox(width: 8),
                            Text(
                              categoria,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? color
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  if (filtroNivel != null || filtroCategoria != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          onNivelChanged(null);
                          onCategoriaChanged(null);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.rojo1.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.rojo1,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Limpiar filtros',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.rojo1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}