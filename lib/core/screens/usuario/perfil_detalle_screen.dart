import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/insignias_screen.dart';
import 'package:tepetl/core/screens/usuario/racha_diaria_screen.dart';
import 'package:tepetl/core/screens/usuario/widgets/perfil_stats_widgets.dart';
import 'package:tepetl/core/services/insignias_service.dart';
import 'package:tepetl/core/services/niveles_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

class PerfilDetalleScreen extends StatefulWidget {
  const PerfilDetalleScreen({super.key});

  @override
  State<PerfilDetalleScreen> createState() => _PerfilDetalleScreenState();
}

class _PerfilDetalleScreenState extends State<PerfilDetalleScreen> {
  late final Stream<DatosInsignias> _stream;

  @override
  void initState() {
    super.initState();
    _stream = InsigniasService.streamDatos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide      = screenWidth > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
      ),
      body: StreamBuilder<DatosInsignias>(
        stream: _stream,
        builder: (context, snap) {
          final datos = snap.data ?? DatosInsignias.vacio;
          final nivel = NivelesService.getNivelByXP(datos.xp);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.03 : 20,
              vertical: 12,
            ),
            child: isWide
                ? _buildWideLayout(context, isDark, screenWidth, datos, nivel)
                : _buildNarrowLayout(context, isDark, datos, nivel),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    bool isDark,
    double screenWidth,
    DatosInsignias datos,
    NivelXP nivel,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: screenWidth * 0.28,
          child: _buildLeftColumn(context, isDark, datos, nivel),
        ),
        const SizedBox(width: 32),
        Expanded(child: _buildRightColumn(context, isDark, datos)),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    bool isDark,
    DatosInsignias datos,
    NivelXP nivel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildLeftColumn(context, isDark, datos, nivel).children,
        const SizedBox(height: 24),
        ..._buildRightColumn(context, isDark, datos).children,
      ],
    );
  }

  Column _buildLeftColumn(
    BuildContext context,
    bool isDark,
    DatosInsignias datos,
    NivelXP nivel,
  ) {
    // Las 3 primeras insignias desbloqueadas para la preview
    final previews = InsigniasService.todas
        .where((d) => datos.tieneInsignia(d.id))
        .take(3)
        .toList();
    // Si hay menos de 3, completa con bloqueadas
    final bloqueadas = InsigniasService.todas
        .where((d) => !datos.tieneInsignia(d.id))
        .take(3 - previews.length);
    final preview3 = [...previews, ...bloqueadas];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Avatar + nombre + nivel ────────────────────────────────
        Center(
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: nivel.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: nivel.color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(nivel.icono, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                'Nivel ${nivel.nivel}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: nivel.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                nivel.nombre,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Stats ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RachaDiariaScreen()),
                ),
                child: TarjetaStat(
                  icono: Icons.local_fire_department,
                  iconColor: AppColors.naranja1,
                  label: 'Racha',
                  valor: '${datos.rachaActual}',
                  delta: 'Días',
                  deltaColor: AppColors.naranja1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TarjetaStat(
                icono: Icons.bolt,
                iconColor: AppColors.amarillo1,
                label: 'XP Total',
                valor: '${datos.xp}',
                delta: nivel.nombre,
                deltaColor: nivel.color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Preview insignias ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Insignias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InsigniasScreen()),
              ),
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secundario,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: preview3.map((def) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InsigniaCirculo(
                def:         def,
                desbloqueada: datos.tieneInsignia(def.id),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Column _buildRightColumn(
    BuildContext context,
    bool isDark,
    DatosInsignias datos,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Camino de insignias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        CaminoInsignias(
          isDark: isDark,
          insigniasDesbloqueadas: datos.insigniasDesbloqueadas,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
