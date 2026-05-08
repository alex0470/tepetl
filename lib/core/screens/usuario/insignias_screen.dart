import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/widgets/perfil_stats_widgets.dart';
import 'package:tepetl/core/services/insignias_service.dart';
import 'package:tepetl/core/services/niveles_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

class InsigniasScreen extends StatefulWidget {
  const InsigniasScreen({super.key});

  @override
  State<InsigniasScreen> createState() => _InsigniasScreenState();
}

class _InsigniasScreenState extends State<InsigniasScreen> {
  late final Stream<DatosInsignias> _stream;

  @override
  void initState() {
    super.initState();
    _stream = InsigniasService.streamDatos();
    // Verifica automáticamente al abrir la pantalla si hay insignias nuevas
    InsigniasService.verificarYOtorgarInsignias().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide      = screenWidth > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text(
          'Tus Insignias',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DatosInsignias>(
        stream: _stream,
        builder: (context, snap) {
          final datos = snap.data ?? DatosInsignias.vacio;
          final nivel = NivelesService.getNivelByXP(datos.xp);
          final progreso = NivelesService.getProgressToNextLevel(datos.xp) / 100.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.03 : 20,
              vertical: 16,
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.24,
                        child: _leftPanel(context, isDark, datos, nivel, progreso),
                      ),
                      const SizedBox(width: 32),
                      Expanded(child: _grid(context, isDark, datos)),
                    ],
                  )
                : Column(
                    children: [
                      _leftPanel(context, isDark, datos, nivel, progreso),
                      const SizedBox(height: 28),
                      _grid(context, isDark, datos),
                      const SizedBox(height: 24),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // ── Panel izquierdo ─────────────────────────────────────────────────────────

  Widget _leftPanel(
    BuildContext context,
    bool isDark,
    DatosInsignias datos,
    NivelXP nivel,
    double progreso,
  ) {
    return Column(
      children: [
        // Icono de nivel
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: nivel.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: nivel.color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(nivel.icono, color: Colors.white, size: 36),
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
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Stats: XP + Racha
        Row(
          children: [
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
            const SizedBox(width: 10),
            Expanded(
              child: TarjetaStat(
                icono: Icons.local_fire_department,
                iconColor: AppColors.naranja1,
                label: 'Racha',
                valor: '${datos.rachaActual}',
                delta: 'Días',
                deltaColor: AppColors.naranja1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Barra de progreso XP
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso al nivel ${nivel.nivel + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${(progreso * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: nivel.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progreso.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(nivel.color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${datos.xp} / ${nivel.xpMax} XP',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Grid por categoría ──────────────────────────────────────────────────────

  Widget _grid(BuildContext context, bool isDark, DatosInsignias datos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: InsigniaCategoria.values.expand((cat) {
        final items       = InsigniasService.porCategoria(cat);
        final disponible  = datos.categoriaPermitida.puedeAcceder(cat);
        return [
          _categoriaHeader(context, cat, disponible),
          const SizedBox(height: 8),
          // Aviso cuando la categoría no está disponible aún
          if (!disponible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.lock_outlined, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Sube de nivel para desbloquear insignias ${cat.nombre}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => InsigniaGridItem(
              def:              items[i],
              desbloqueada:     datos.tieneInsignia(items[i].id),
              bloqueadaPorNivel: !disponible,
            ),
          ),
          const SizedBox(height: 24),
        ];
      }).toList(),
    );
  }

  Widget _categoriaHeader(BuildContext context, InsigniaCategoria cat, bool disponible) {
    final color = disponible ? cat.color : Colors.grey.shade400;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          cat.nombre.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: color,
          ),
        ),
        if (!disponible) ...[
          const SizedBox(width: 6),
          Icon(Icons.lock_outlined, size: 12, color: Colors.grey.shade400),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: color.withValues(alpha: 0.25),
            height: 1,
          ),
        ),
      ],
    );
  }
}
