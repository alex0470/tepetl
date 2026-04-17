import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/examen_nivel_screen.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/completar.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class _MiCurso {
  final String titulo;
  final String modulo;
  final String imagen;
  final double progreso;
  final String botonLabel;

  const _MiCurso({
    required this.titulo,
    required this.modulo,
    required this.imagen,
    required this.progreso,
    required this.botonLabel,
  });
}

class _CursoOficial {
  final String titulo;
  final String descripcion;
  final String imagen;
  final String nivel;
  final Color nivelColor;
  final String alumnos;

  const _CursoOficial({
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.nivel,
    required this.nivelColor,
    required this.alumnos,
  });
}

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

// ── Datos Iniciales (Base) ────────────────────────────────────────────────────

final List<_MiCurso> _misCursosIniciales = [
  const _MiCurso(
    titulo: 'Náhuatl Intermedio',
    modulo: 'Módulo 1: Verbos de movimiento',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=200&h=200',
    progreso: 0.0,
    botonLabel: 'Comenzar',
  ),
  const _MiCurso(
    titulo: 'Náhuatl Básico',
    modulo: 'Módulo 2: Animales y naturaleza',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/lluvia-cayendo-sobre-plantas-866138.png?w=200&h=200',
    progreso: 0.20,
    botonLabel: 'Continuar',
  ),
];

List<_CursoOficial> _cursosOficiales = [
  _CursoOficial(
    titulo: 'Variante Guerrero Central',
    descripcion:
        'Aprende la variante hablada en la región montañosa de Guerrero con énfasis en el habla cotidiana.',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=600&h=400',
    nivel: 'INTERMEDIO',
    nivelColor: AppColors.amarillo1.withValues(alpha: 0.3),
    alumnos: '1.2k alumnos',
  ),
  _CursoOficial(
    titulo: 'Poesía y Canto Náhuatl',
    descripcion:
        'Explora la riqueza literaria de los antiguos cantares mexicanos y la métrica de la poesía clásica.',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/lluvia-cayendo-sobre-plantas-866138.png?w=600&h=400',
    nivel: 'BÁSICO',
    nivelColor: AppColors.secundario.withValues(alpha: 0.3),
    alumnos: '850 alumnos',
  ),
  _CursoOficial(
    titulo: 'Cosmovisión y Mitos',
    descripcion:
        'Un viaje a través de los mitos de creación, los dioses y el concepto del tiempo en el pensamiento náhuatl.',
    imagen:
        'https://69cd7410079511ce6100f7d7.imgix.net/flower.png?w=600&h=400',
    nivel: 'BÁSICO',
    nivelColor: AppColors.secundario.withValues(alpha: 0.3),
    alumnos: '2.1k alumnos',
  ),
];

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

class CursosScreen extends StatefulWidget {
  const CursosScreen({super.key});

  @override
  State<CursosScreen> createState() => _CursosScreenState();
}

class _CursosScreenState extends State<CursosScreen> {
  // Lista de cursos de estado local para poder agregar dinámicamente
  List<_MiCurso> misCursos = List.from(_misCursosIniciales);

  void _inscribirCurso(_CursoOficial oficial) {
    setState(() {
      misCursos.add(
        _MiCurso(
          titulo: oficial.titulo,
          modulo: 'Módulo 1: Introducción',
          imagen: oficial.imagen,
          progreso: 0.0,
          botonLabel: 'Comenzar',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    // Ajuste de breakpoint para evitar desbordamientos en tablets grandes/pantallas medianas
    final isWide = sw > 1000;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      body: SafeArea(
        child: isWide
            ? _WideLayout(
                isDark: isDark,
                misCursos: misCursos,
                onInscribir: _inscribirCurso,
              )
            : _MobileLayout(
                isDark: isDark,
                misCursos: misCursos,
                onInscribir: _inscribirCurso,
              ),
      ),
    );
  }
}

// ── Layout Móvil ──────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final bool isDark;
  final List<_MiCurso> misCursos;
  final Function(_CursoOficial) onInscribir;

  const _MobileLayout({
    required this.isDark,
    required this.misCursos,
    required this.onInscribir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SeccionMisCursos(isDark: isDark, isWide: false, misCursos: misCursos),
          const SizedBox(height: 24),
          _SeccionSugerencias(isDark: isDark, isWide: false),
          const SizedBox(height: 24),
          _SeccionExplorar(isDark: isDark, isWide: false, onInscribir: onInscribir),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Layout Ancho ──────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final bool isDark;
  final List<_MiCurso> misCursos;
  final Function(_CursoOficial) onInscribir;

  const _WideLayout({
    required this.isDark,
    required this.misCursos,
    required this.onInscribir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lado Izquierdo: Mis cursos y Explorar (del mismo ancho de columna)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SeccionMisCursos(
                    isDark: isDark, isWide: true, misCursos: misCursos),
                const SizedBox(height: 32),
                _SeccionExplorar(
                    isDark: isDark, isWide: true, onInscribir: onInscribir),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Lado Derecho: Sugerencias IA (Ajustado a 340 para dar más aire al contenido principal)
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
  final List<_MiCurso> misCursos;

  const _SeccionMisCursos({
    required this.isDark,
    required this.isWide,
    required this.misCursos,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secundario.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${misCursos.length} ACTIVOS',
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
        // Implementación 100% responsiva para Mis Cursos
        LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            int columns = w > 650 ? 2 : 1;
            double spacing = 16.0;
            double itemWidth = (w - (columns - 1) * spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: misCursos
                  .map(
                    (c) => SizedBox(
                      width: itemWidth,
                      child: _TarjetaCurso(curso: c, isDark: isDark),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TarjetaCurso extends StatelessWidget {
  final _MiCurso curso;
  final bool isDark;
  const _TarjetaCurso({required this.curso, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = (curso.progreso * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
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
          // Imagen + info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  curso.imagen,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 20),
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
                      curso.modulo,
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra de progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.60),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: curso.progreso,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.20),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.secundario),
            ),
          ),
          const SizedBox(height: 14),
          // Acciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cancel_outlined,
                      color: AppColors.rojo1, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    'ANULAR INSCRIPCIÓN',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.rojo1,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  // NAVEGACIÓN A PlantillaCompletar
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExamenNivelScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    curso.botonLabel,
                    style: const TextStyle(
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
      {required this.sugerencia,
      required this.isDark,
      required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      height: 215, // Altura fija para que todas midan exactamente lo mismo
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.40),
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
              color: Theme.of(  context).colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const Spacer(), // Empuja el botón obligatoriamente hacia el fondo de la tarjeta
          SizedBox(
            width: double.infinity,
            height: 43,
            child: sugerencia.botonOscuro
                ? ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamenNivelScreen(),
                        ),
                      );
                    },
                    icon: Icon(sugerencia.icono, size: 14),
                    label: Text(
                      sugerencia.botonLabel,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primario,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamenNivelScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primario,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      sugerencia.botonLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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
              Icon(Icons.forum_outlined,
                  size: 14, color: AppColors.secundario),
              const SizedBox(width: 6),
              Text(
                'Foro del día',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"¿Cómo se dice \'pueblo\' en tu variante local?"',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
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

// ── Sección: Explorar cursos oficiales ───────────────────────────────────────

class _SeccionExplorar extends StatelessWidget {
  final bool isDark;
  final bool isWide;
  final Function(_CursoOficial) onInscribir;
  const _SeccionExplorar(
      {required this.isDark, required this.isWide, required this.onInscribir});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPLORAR CURSOS OFICIALES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        // Implementación 100% responsiva para Cursos Oficiales
        LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            // 3 columnas en pantallas muy grandes, 2 en pantallas medias, 1 en móvil
            int columns = w > 850 ? 3 : (w > 550 ? 2 : 1);
            double spacing = 16.0;
            double itemWidth = (w - (columns - 1) * spacing) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _cursosOficiales
                  .map(
                    (c) => SizedBox(
                      width: itemWidth,
                      child: _TarjetaCursoOficial(
                          curso: c, isDark: isDark, onInscribir: onInscribir),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TarjetaCursoOficial extends StatelessWidget {
  final _CursoOficial curso;
  final bool isDark;
  final Function(_CursoOficial) onInscribir;

  const _TarjetaCursoOficial({
    required this.curso,
    required this.isDark,
    required this.onInscribir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350, // Altura estricta para que todas las cards midan lo mismo
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
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
                Image.network(
                  curso.imagen,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 140,
                    color: Colors.grey.shade800,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: curso.nivelColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      curso.nivel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido Expandido para obligar a que los elementos del fondo bajen igual
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    curso.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    curso.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const Spacer(), // Asegura que el footer se ancle en la parte de abajo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            curso.alumnos,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          // POPUP Y AÑADIR A LISTA
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('¡Inscripción Exitosa!'),
                                content: Text(
                                    'Te has inscrito al curso "${curso.titulo}". Se ha agregado a tu lista de cursos.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      onInscribir(curso);
                                    },
                                    child: const Text('Aceptar'),
                                  )
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secundario,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Inscribirme',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
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