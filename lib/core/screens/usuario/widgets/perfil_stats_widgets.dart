import 'package:flutter/material.dart';
import 'package:tepetl/core/services/insignias_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ── Tarjeta de estadística ────────────────────────────────────────────────────

class TarjetaStat extends StatelessWidget {
  final IconData icono;
  final Color iconColor;
  final String label;
  final String valor;
  final String delta;
  final Color deltaColor;

  const TarjetaStat({
    super.key,
    required this.icono,
    required this.iconColor,
    required this.label,
    required this.valor,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
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
          Icon(icono, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            delta,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: deltaColor),
          ),
        ],
      ),
    );
  }
}

// ── Círculo de insignia (perfil detalle, preview) ─────────────────────────────

class InsigniaCirculo extends StatelessWidget {
  final InsigniaDef def;
  final bool desbloqueada;

  const InsigniaCirculo({
    super.key,
    required this.def,
    required this.desbloqueada,
  });

  @override
  Widget build(BuildContext context) {
    final color = def.categoria.color;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: desbloqueada
                ? color.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: desbloqueada
                  ? color.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: desbloqueada
                ? Icon(def.icono, size: 26, color: def.categoria.color)
                : Icon(Icons.lock_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 22),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          def.nombre,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ── Item del grid de insignias ────────────────────────────────────────────────

class InsigniaGridItem extends StatelessWidget {
  final InsigniaDef def;
  final bool desbloqueada;
  /// true cuando la insignia no está disponible por nivel educativo insuficiente
  final bool bloqueadaPorNivel;

  const InsigniaGridItem({
    super.key,
    required this.def,
    required this.desbloqueada,
    this.bloqueadaPorNivel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = def.categoria.color;
    // Apariencia reducida cuando la categoría no está disponible por nivel
    final opacidad = bloqueadaPorNivel ? 0.35 : (desbloqueada ? 1.0 : 0.7);

    return Opacity(
      opacity: opacidad,
      child: Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        border: desbloqueada && !bloqueadaPorNivel
            ? Border.all(color: color.withValues(alpha: 0.45), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: desbloqueada && !bloqueadaPorNivel
                  ? color.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: desbloqueada && !bloqueadaPorNivel
                  ? Icon(def.icono, size: 26, color: color)
                  : Icon(
                      bloqueadaPorNivel ? Icons.lock_outlined : Icons.lock_outline,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.35),
                      size: 22),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            def.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: desbloqueada && !bloqueadaPorNivel
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            bloqueadaPorNivel
                ? 'Sube de nivel'
                : (desbloqueada ? '¡Conseguido!' : def.descripcion),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: desbloqueada
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontWeight: desbloqueada ? FontWeight.w700 : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ), // Container
    ); // Opacity
  }
}

// ── Camino de insignias ───────────────────────────────────────────────────────
// Muestra las insignias de las 3 categorías en un timeline vertical.

class CaminoInsignias extends StatelessWidget {
  final bool isDark;
  final Set<String> insigniasDesbloqueadas;

  const CaminoInsignias({
    super.key,
    required this.isDark,
    required this.insigniasDesbloqueadas,
  });

  @override
  Widget build(BuildContext context) {
    final categorias = InsigniaCategoria.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categorias.expand((cat) {
        final items = InsigniasService.porCategoria(cat);
        return [
          // Encabezado de categoría
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: cat.color,
                  ),
                ),
              ],
            ),
          ),
          // Insignias de la categoría
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            final def    = e.value;
            final unlock = insigniasDesbloqueadas.contains(def.id);
            return _FilaCamino(
              def:      def,
              unlock:   unlock,
              isLast:   isLast && cat == categorias.last,
            );
          }),
          const SizedBox(height: 8),
        ];
      }).toList(),
    );
  }
}

class _FilaCamino extends StatelessWidget {
  final InsigniaDef def;
  final bool unlock;
  final bool isLast;

  const _FilaCamino({
    required this.def,
    required this.unlock,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = def.categoria.color;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea de timeline
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: unlock ? color : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: unlock
                      ? const Icon(Icons.check, size: 9, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(
                    def.icono,
                    size: 22,
                    color: unlock
                        ? def.categoria.color
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              def.nombre,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: unlock
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            if (unlock) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  def.categoria.nombre,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          def.descripcion,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.6),
                            height: 1.3,
                          ),
                        ),
                      ],
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
