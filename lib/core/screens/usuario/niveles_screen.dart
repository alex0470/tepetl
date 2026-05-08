import 'package:flutter/material.dart';
import 'package:tepetl/core/services/niveles_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

class NivelesScreen extends StatelessWidget {
  final int xpActual;

  const NivelesScreen({super.key, required this.xpActual});

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final nivelActual = NivelesService.getNivelByXP(xpActual);
    final progreso    = NivelesService.getProgressToNextLevel(xpActual) / 100.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text(
          'Todos los niveles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Banner nivel actual ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: nivelActual.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: nivelActual.color.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(nivelActual.icono, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NIVEL ${nivelActual.nivel} · ${nivelActual.categoria.nombre.toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nivelActual.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progreso,
                              minHeight: 5,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$xpActual / ${nivelActual.xpMax} XP · ${(progreso * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Secciones por categoría ──────────────────────────────────────
          ...NivelCategoria.values.expand((cat) {
            final items = NivelesService.porCategoria(cat);
            return <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: cat.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat.nombre.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: cat.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: cat.color.withValues(alpha: 0.25),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final n        = items[i];
                    final alcanzado = xpActual >= n.xpMin;
                    final esCurrent = n.nivel == nivelActual.nivel;
                    return _NivelRow(
                      nivel: n,
                      alcanzado: alcanzado,
                      esCurrent: esCurrent,
                      isDark: isDark,
                    );
                  },
                  childCount: items.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ];
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _NivelRow extends StatelessWidget {
  final NivelXP nivel;
  final bool alcanzado;
  final bool esCurrent;
  final bool isDark;

  const _NivelRow({
    required this.nivel,
    required this.alcanzado,
    required this.esCurrent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = nivel.color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: esCurrent
            ? color.withValues(alpha: 0.12)
            : isDark
                ? AppColors.fondoOscuroSecundario
                : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(14),
        border: esCurrent ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5) : null,
      ),
      child: Row(
        children: [
          // Icono de nivel
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: alcanzado
                  ? color.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              alcanzado ? nivel.icono : Icons.lock_outline,
              size: 20,
              color: alcanzado
                  ? color
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 14),

          // Nombre y XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Nivel ${nivel.nivel}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: alcanzado ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                    if (esCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTUAL',
                          style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  nivel.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: alcanzado
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),

          // XP requerido + check
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              alcanzado
                  ? Icon(Icons.check_circle, color: color, size: 20)
                  : Icon(Icons.radio_button_unchecked,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      size: 20),
              const SizedBox(height: 2),
              Text(
                '${nivel.xpMin} XP',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
