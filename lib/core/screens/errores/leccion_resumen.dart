// lesson_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:tepetl/core/models/modelo_revision.dart';
import 'package:tepetl/core/screens/errores/revision_errores.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/screens/principales/inicio.dart';

class LeccionResumen extends StatelessWidget {
  final ResultadoLeccion result;

  const LeccionResumen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isWide = sw > 700;
    final double contentWidth =
        isWide ? (sw * 0.75).clamp(800, 1200) : double.infinity;

    void onReviewErrors() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RevisionErrores(errores: result.errores),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),

            Expanded(
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: isWide
                      // ── Desktop: dos columnas ─────────────────────────
                      ? Padding(
                          padding: EdgeInsets.all(sw * 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Columna izquierda
                              Expanded(
                                flex: 5,
                                child: Center( // 👈 AGREGA ESTO
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 600),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          _HeroBanner(),
                                          const SizedBox(height: 24),
                                          _PrecisionCard(result: result),
                                          const SizedBox(height: 16),
                                          _StatsRow(result: result),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                              const SizedBox(width: 20),

                              // Columna derecha
                              Expanded(
                                flex: 6,
                                child: Center( // 👈 AGREGA ESTO
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 650),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          _AIAnalysisCard(message: result.mensajeAI),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _ReviewErrorsButton(
                                                    onTap: onReviewErrors),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _ContinueButton(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        )
                      // ── Móvil: columna única ──────────────────────────
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(sw * 0.04),
                          child: Column(
                            children: [
                              _HeroBanner(),
                              const SizedBox(height: 16),
                              _PrecisionCard(result: result),
                              const SizedBox(height: 12),
                              _StatsRow(result: result),
                              const SizedBox(height: 16),
                              _AIAnalysisCard(message: result.mensajeAI),
                              const SizedBox(height: 24),
                              _ContinueButton(),
                              const SizedBox(height: 12),
                              _ReviewErrorsButton(onTap: onReviewErrors),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(Icons.close,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              'RESUMEN DE LA LECCIÓN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.azulAqua, AppColors.azul1, AppColors.morado1],
                ),
              ),
              child: const Icon(Icons.hide_image, size: 80, color: Colors.white24),
            ),
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                ),
              ),
            ),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.secundario,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Lección Completada!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Has dominado el vocabulario básico.',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Precision Card ────────────────────────────────────────────────────────────

class _PrecisionCard extends StatelessWidget {
  final ResultadoLeccion result;
  const _PrecisionCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark
        ? AppColors.fondoOscuroSecundario
        : AppColors.fondoSecundario;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRECISIÓN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${result.precision}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secundario.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${result.precisionDelta}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secundario,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _CircularProgress(value: result.precision / 100),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double value;
  const _CircularProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 6,
            backgroundColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.1),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.secundario),
          ),
          const Icon(Icons.check, color: AppColors.secundario, size: 22),
        ],
      ),
    );
  }
}

// ── Stats Row (XP + Time) ─────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final ResultadoLeccion result;
  const _StatsRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'XP GANADOS',
            value: '+${result.xpGanada} XP',
            icon: Icons.bolt,
            iconColor: AppColors.amarillo1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'TIEMPO',
            value: result.tiempo,
            icon: Icons.access_time,
            iconColor: AppColors.azul1,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark
        ? AppColors.fondoOscuroSecundario
        : AppColors.fondoSecundario;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 28),
        ],
      ),
    );
  }
}

// ── AI Analysis Card ──────────────────────────────────────────────────────────

class _AIAnalysisCard extends StatelessWidget {
  final String message;
  const _AIAnalysisCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome,
                color: AppColors.morado1, size: 18),
            const SizedBox(width: 6),
            Text(
              'Análisis de la IA',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.fondoOscuroSecundario
                : AppColors.fondoSecundario,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.morado1.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.record_voice_over,
                    color: AppColors.morado1, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Gran trabajo!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (ctx, a1, a2) => const MainScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secundario,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Continuar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewErrorsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ReviewErrorsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.fondoOscuroSecundario
                : AppColors.fondoSecundario,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Revisar Errores',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}