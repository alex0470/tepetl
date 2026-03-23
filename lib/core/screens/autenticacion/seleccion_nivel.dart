import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';

class NivelSeleccionScreen extends StatelessWidget {
  const NivelSeleccionScreen({super.key});

  static const double _kBreakpoint = 700;

  static const double _cardWideWidth    = 450;
  static const double _cardNarrowWidth  = 350;
  static const double _cardWideHeight   = 550;
  static const double _cardNarrowHeight = 400;

  Color _cardBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario;
  }

  List<BoxShadow> _cardShadow(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 2,
        offset: const Offset(4, 4),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= _kBreakpoint;
          return isWide ? _wideLayout(context) : _narrowLayout(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LAYOUT ESTRECHO
  // ─────────────────────────────────────────────
  Widget _narrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: BotonAtras(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _header(context),
          ),

          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              width: _cardNarrowWidth,
              height: _cardNarrowHeight,
              child: _diagnosticCard(context, wide: false),
            ),
          ),

          const SizedBox(height: 28),

          _divider(context),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _levelTile(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  iconBg: AppColors.naranja1.withValues(alpha: 0.2),
                  iconColor: AppColors.naranja1,
                  title: 'Básico',
                  subtitle: '(Tlapehualiztli)',
                  desc: 'Empiezas desde cero. Palabras simples y saludos.',
                ),
                const SizedBox(height: 12),
                _levelTile(
                  context,
                  icon: Icons.extension_outlined,
                  iconBg: AppColors.azul1.withValues(alpha: 0.2),
                  iconColor: AppColors.azul1,
                  title: 'Intermedio',
                  subtitle: '(Tlahco)',
                  desc: 'Puedes formar frases y entender contextos cotidianos.',
                ),
                const SizedBox(height: 12),
                _levelTile(
                  context,
                  icon: Icons.auto_stories_outlined,
                  iconBg: AppColors.morado1.withValues(alpha: 0.2),
                  iconColor: AppColors.morado1,
                  title: 'Avanzado',
                  subtitle: '(Hueyi)',
                  desc: 'Conversación fluida y textos complejos tradicionales.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LAYOUT ANCHO
  // ─────────────────────────────────────────────
  Widget _wideLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: BotonAtras(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
            child: _header(context),
          ),

          const SizedBox(height: 28),

          // ── Fila principal: card diagnóstica + sección manual ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card diagnóstica
                SizedBox(
                  width: _cardWideWidth,
                  height: _cardWideHeight,
                  child: _diagnosticCard(context, wide: true),
                ),

                const SizedBox(width: 32),

                // Columna "elige manualmente" — centrada
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'O elige manualmente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cards de nivel centradas en el espacio disponible
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _levelCard(
                                context,
                                icon: Icons.wb_sunny_outlined,
                                iconBg: AppColors.naranja1.withValues(alpha: 0.2),
                                iconColor: AppColors.naranja1,
                                title: 'Básico',
                                subtitle: '(Tlapehualiztli)',
                                desc: 'Empiezas desde cero. Palabras simples y saludos.',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _levelCard(
                                context,
                                icon: Icons.extension_outlined,
                                iconBg: AppColors.azul1.withValues(alpha: 0.2),
                                iconColor: AppColors.azul1,
                                title: 'Intermedio',
                                subtitle: '(Tlahco)',
                                desc: 'Puedes formar frases y entender contextos cotidianos.',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _levelCard(
                                context,
                                icon: Icons.auto_stories_outlined,
                                iconBg: AppColors.morado1.withValues(alpha: 0.2),
                                iconColor: AppColors.morado1,
                                title: 'Avanzado',
                                subtitle: '(Hueyi)',
                                desc: 'Conversación fluida y textos complejos tradicionales.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                children: [
                  const TextSpan(text: '¿No estás seguro? Te recomendamos usar la '),
                  TextSpan(
                    text: 'Evaluación Diagnóstica',
                    style: TextStyle(
                      color: AppColors.secundario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WIDGETS COMPARTIDOS
  // ─────────────────────────────────────────────
  Widget _header(BuildContext context) {
    return Column(
      children: [
        Text(
          '¡Bienvenido a Tepetl!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Para personalizar tu camino de aprendizaje del Náhuatl,\nnecesitamos conocer tu punto de partida.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _diagnosticCard(BuildContext context, {required bool wide}) {
    final double imgHeight = (wide ? _cardWideHeight : _cardNarrowHeight) - 220;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              width: double.infinity,
              height: imgHeight,
              color: AppColors.secundario.withValues(alpha: 0.3),
              child: Center(
                child: Icon(
                  Icons.psychology_outlined,
                  size: wide ? 90 : 64,
                  color: AppColors.secundario,
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Evaluación Diagnóstica',
                          style: TextStyle(
                            fontSize: wide ? 22 : 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secundario.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'RECOMENDADO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secundario,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Deja que nuestro sistema determine tu nivel exacto con una breve prueba adaptativa de 5 minutos.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: BotonesSombra(
                      text: 'Comenzar prueba',
                      onPressed: () {},
                      width: 250,
                      height: 50,
                      backgroundColor: AppColors.primario,
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

  Widget _divider(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        const SizedBox(width: 24),
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'O elige manualmente',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _levelTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String desc,
  }) {
    // ── Reemplazado InkWell → _PressableCard ──
    return _PressableCard(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardBg(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow(context),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' $subtitle',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String desc,
  }) {
    // ── Reemplazado InkWell → _PressableCard ──
    return _PressableCard(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const _PressableCard({
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    reverseDuration: const Duration(milliseconds: 160),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.95,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _)     => _ctrl.reverse();
  void _onTapCancel()               => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}