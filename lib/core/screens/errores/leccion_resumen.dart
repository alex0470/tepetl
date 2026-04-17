import 'package:flutter/material.dart';
import 'package:tepetl/core/models/modelo_revision.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class LeccionResumen extends StatelessWidget {
  final ResultadoLeccion result;

  const LeccionResumen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isWide = sw > 700;
    final double contentWidth =
        isWide ? (sw * 0.75).clamp(800, 1200) : double.infinity;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Cabezal con icono de éxito
            const _HeaderSection(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // 1. Mensaje de la IA (Respuesta del servicio)
                        _IAMessageCard(mensaje: result.mensajeAI),

                        const SizedBox(height: 30),

                        // 2. Cuadrícula de Estadísticas (Precisión, XP, Tiempo)
                        _StatsGrid(
                          precision: result.precision,
                          xp: result.xpGanada,
                          tiempo: result.tiempo,
                        ),

                        const SizedBox(height: 40),

                        // 3. Botón de Revisar Errores (solo si hubo errores)
                        if (result.errores.isNotEmpty)
                          _ActionButton(
                            text: 'Revisar Errores',
                            isPrimary: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainScreen(),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 16),

                        // 4. Botón de Continuar
                        _ActionButton(
                          text: 'Continuar',
                          isPrimary: true,
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const MainScreen()),
                              (route) => false,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 30),
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

// ── SECCIÓN: Cabezal ─────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.secundario,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Examen Finalizado!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SECCIÓN: Mensaje de la IA ────────────────────────────────────────────────
class _IAMessageCard extends StatelessWidget {
  final String mensaje;

  const _IAMessageCard({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secundario.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secundario.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.secundario, size: 20),
              const SizedBox(width: 8),
              Text(
                'EVALUACIÓN DE IA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.secundario.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SECCIÓN: Grid de Estadísticas ────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final int precision;
  final int xp;
  final String tiempo;

  const _StatsGrid({
    required this.precision,
    required this.xp,
    required this.tiempo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          label: 'PRECISIÓN',
          value: '$precision%',
          icon: Icons.track_changes,
          color: Colors.orange,
        ),
        _StatItem(
          label: 'XP GANADA',
          value: '+$xp',
          icon: Icons.bolt,
          color: Colors.yellow.shade700,
        ),
        _StatItem(
          label: 'TIEMPO',
          value: tiempo,
          icon: Icons.timer_outlined,
          color: Colors.blue,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// ── SECCIÓN: Botones de Acción ───────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? AppColors.secundario 
              : Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.fondoOscuroSecundario 
                  : Colors.grey.shade200,
          foregroundColor: isPrimary 
              ? Colors.white 
              : Theme.of(context).colorScheme.onSurface,
          elevation: isPrimary ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}