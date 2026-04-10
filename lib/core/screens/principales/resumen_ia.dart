import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────

class _PuntoFuerte {
  final IconData icono;
  final Color iconColor;
  final Color iconBg;
  final String porcentaje;
  final String etiqueta;

  const _PuntoFuerte({
    required this.icono,
    required this.iconColor,
    required this.iconBg,
    required this.porcentaje,
    required this.etiqueta,
  });
}

class _PalabraReforzar {
  final IconData icono;
  final Color iconColor;
  final Color iconBg;
  final String palabra;
  final String traduccion;

  const _PalabraReforzar({
    required this.icono,
    required this.iconColor,
    required this.iconBg,
    required this.palabra,
    required this.traduccion,
  });
}

// ── Datos ─────────────────────────────────────────────────────────────────────

List<_PuntoFuerte> _puntosFuertes = [
  _PuntoFuerte(
    icono: Icons.record_voice_over_outlined,
    iconColor: AppColors.azul1,
    iconBg: AppColors.azul1.withValues(alpha: 0.2),
    porcentaje: '92%',
    etiqueta: 'Pronunciación',
  ),
  _PuntoFuerte(
    icono: Icons.menu_book_outlined,
    iconColor: AppColors.amarillo1,
    iconBg: AppColors.amarillo1.withValues(alpha: 0.2),
    porcentaje: '90%',
    etiqueta: 'Lectura',
  ),
];

List<_PalabraReforzar> _palabras = [
  _PalabraReforzar(
    icono: Icons.school_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Tlazocamati',
    traduccion: 'Gracias',
  ),
  _PalabraReforzar(
    icono: Icons.pets_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Misto',
    traduccion: 'Gato',
  ),
  _PalabraReforzar(
    icono: Icons.home_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Calli',
    traduccion: 'Casa',
  ),
  _PalabraReforzar(
    icono: Icons.woman_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Cihuatl',
    traduccion: 'Mujer',
  ),
  _PalabraReforzar(
    icono: Icons.man_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Oquichtli',
    traduccion: 'Hombre',
  ),
  // Añadimos dos más para que el botón de "Ver todas" tenga efecto visual
  _PalabraReforzar(
    icono: Icons.park_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Cuahuitl',
    traduccion: 'Árbol',
  ),
  _PalabraReforzar(
    icono: Icons.water_drop_outlined,
    iconColor: AppColors.secundario,
    iconBg: AppColors.secundario.withValues(alpha: 0.2),
    palabra: 'Atl',
    traduccion: 'Agua',
  ),
];

// ── Pantalla principal ────────────────────────────────────────────────────────

class ResumenIAScreen extends StatelessWidget {
  const ResumenIAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 800;

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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TarjetaPerfilSaludo(isDark: isDark),
          const SizedBox(height: 16),
          _TarjetaPuntosFuertes(isDark: isDark),
          const SizedBox(height: 20),
          _SeccionPalabras(isDark: isDark),
          const SizedBox(height: 20),
          _SeccionConsejo(isDark: isDark),
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
          // Columna izquierda fija
          SizedBox(
            width: 550,
            child: Column(
              children: [
                _TarjetaPerfilSaludo(isDark: isDark),
                const SizedBox(height: 16),
                _TarjetaPuntosFuertes(isDark: isDark),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Columna derecha expandida
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SeccionPalabras(isDark: isDark),
                const SizedBox(height: 20),
                _SeccionConsejo(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta: Perfil + Saludo ──────────────────────────────────────────────────

class _TarjetaPerfilSaludo extends StatelessWidget {
  final bool isDark;
  const _TarjetaPerfilSaludo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isDark
                    ? AppColors.extraOscuro120
                    : AppColors.extra120,
                child: const Text(
                  'G',
                  style: TextStyle(
                    color: AppColors.primario,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.naranja1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¡Cualli tonalli, Alex!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'He analizado tus últimas sesiones. Aquí está tu resumen de hoy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta: Puntos fuertes ───────────────────────────────────────────────────

class _TarjetaPuntosFuertes extends StatelessWidget {
  final bool isDark;
  const _TarjetaPuntosFuertes({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Puntos fuertes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Esta semana',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secundario,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _puntosFuertes.asMap().entries.map((e) {
              final isLast = e.key == _puntosFuertes.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 10),
                  child: _TarjetaMetrica(punto: e.value, isDark: isDark),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  final _PuntoFuerte punto;
  final bool isDark;
  const _TarjetaMetrica({required this.punto, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: punto.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(punto.icono, color: punto.iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            punto.porcentaje,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            punto.etiqueta,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}

// ── Sección: Palabras por reforzar ────────────────────────────────────────────

class _SeccionPalabras extends StatefulWidget {
  final bool isDark;
  const _SeccionPalabras({required this.isDark});

  @override
  State<_SeccionPalabras> createState() => _SeccionPalabrasState();
}

class _SeccionPalabrasState extends State<_SeccionPalabras> {
  bool _mostrarTodas = false;

  @override
  Widget build(BuildContext context) {
    // Cambio: Mostrar 5 en lugar de 3 inicialmente
    final palabrasAMostrar = _mostrarTodas ? _palabras : _palabras.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Palabras por reforzar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
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
            children: palabrasAMostrar.asMap().entries.map((entry) {
              final isLast = entry.key == palabrasAMostrar.length - 1;
              return Column(
                children: [
                  _FilaPalabra(palabra: entry.value, isDark: widget.isDark),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Cambio: Centrar el botón
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _mostrarTodas = !_mostrarTodas;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Agregué un poco más de padding horizontal para facilitar el tap
              child: Text(
                _mostrarTodas ? 'Ocultar palabras' : 'Ver todas las palabras difíciles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secundario,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilaPalabra extends StatelessWidget {
  final _PalabraReforzar palabra;
  final bool isDark;
  const _FilaPalabra({required this.palabra, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palabra.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(palabra.icono, color: palabra.iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  palabra.palabra,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  palabra.traduccion,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección: Consejo del día ──────────────────────────────────────────────────

class _SeccionConsejo extends StatelessWidget {
  final bool isDark;
  const _SeccionConsejo({required this.isDark});

  void _mostrarConsejosModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cambio: Mantener la imagen en el popup
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=800&h=400',
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(height: 200, color: const Color(0xFF1A1A2E)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consejos Prácticos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secundario.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.record_voice_over, color: AppColors.secundario),
                      ),
                      title: Text(
                        'El sonido "TL"',
                        // Cambio: Tamaño definido para el título
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Recuerda que "tl" es un solo chasquido lateral, no dos letras separadas. Intenta poner la lengua en el paladar y deja escapar el aire por los lados.',
                          // Cambio: Tamaño del consejo (subtítulo) más pequeño que el título
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.naranja1.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb_outline, color: AppColors.naranja1),
                      ),
                      title: Text(
                        'Práctica Diaria',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Repasar 5 minutos al día es mucho más efectivo para la memoria que estudiar 1 hora entera a la semana.',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.azul1.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.hearing, color: AppColors.azul1),
                      ),
                      title: Text(
                        'Acentuación',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Presta atención a la acentuación de las palabras al escuchar, casi todas las palabras son graves.',
                          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejo del día',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _mostrarConsejosModal(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Image.network(
                  'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=800&h=400',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(height: 200, color: const Color(0xFF1A1A2E)),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.25, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 18,
                  right: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secundario,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'GRAMÁTICA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "El sonido 'TL'",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Recuerda que 'tl' es un solo chasquido lateral, no dos letras separadas. Intenta poner la lengua en el paladar y deja escapar el aire por los lados...",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Text(
                            'Seguir leyendo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}