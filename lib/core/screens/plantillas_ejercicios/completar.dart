import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/inicio.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/usuario/progreso_map.dart';

class PlantillaCompletar extends StatefulWidget {
  const PlantillaCompletar({super.key});

  @override
  State<PlantillaCompletar> createState() => _PlantillaCompletarState();
}

class _PlantillaCompletarState extends State<PlantillaCompletar> {
  String? selectedWord;

  final List<String> options = ['niquihtoa', 'nitlahtoa', 'nimitztlazohtla'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) => const InicioScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    },
                    child: const Icon(Icons.close, size: 24),
                  ),
                  const Spacer(),
                  const Text(
                    'EXPRESIÓN ESCRITA',
                    style: TextStyle(
                      color: AppColors.secundario,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4B4B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.favorite, color: Colors.white, size: 15),
                        SizedBox(width: 4),
                        Text(
                          '5',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LECCIÓN 2',
                    style: TextStyle(
                      color: AppColors.secundario,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.45,
                            minHeight: 10,
                            backgroundColor: AppColors.secundario.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.secundario,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '45%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secundario.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.record_voice_over_outlined,
                color: Colors.white,
                size: 38,
              ),
            ),

            const SizedBox(height: 28),

            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: 'Nehuatl '),
                  TextSpan(
                    text: 'nitlahtoa',
                    style: TextStyle(color: AppColors.secundario),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Nahuatlahtolli',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '(Hablo Náhuatl)',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textoSecundario40,
              ),
            ),

            const Spacer(),

            const Text(
              'SELECCIONA LA PALABRA QUE FALTA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textoSecundario40,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 16),

            // ── Word options ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Row 1: niquihtoa | nitlahtoa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _OptionChip(
                        label: 'niquihtoa',
                        selected: selectedWord == 'niquihtoa',
                        correct: false,
                        onTap: () => setState(() => selectedWord = 'niquihtoa'),
                      ),
                      const SizedBox(width: 12),
                      _OptionChip(
                        label: 'nitlahtoa',
                        selected: selectedWord == 'nitlahtoa',
                        correct: true,
                        onTap: () => setState(() => selectedWord = 'nitlahtoa'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row 2: nimitztlazohtla (centered)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _OptionChip(
                        label: 'nimitztlazohtla',
                        selected: selectedWord == 'nimitztlazohtla',
                        correct: false,
                        onTap: () =>
                            setState(() => selectedWord = 'nimitztlazohtla'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(width: 16),
                Icon(Icons.lightbulb_outline,
                    color: AppColors.secundario, size: 18),
                SizedBox(width: 6),
                Text(
                  '¿Necesitas una pista?',
                  style: TextStyle(
                    color: AppColors.secundario,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Verify button ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedWord != null ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario,
                    disabledBackgroundColor: AppColors.secundario.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verificar Respuesta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

// ── Reusable chip widget ──────────────────────────────────────────────────────
class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool correct; // true = this chip is the right answer (yellow when selected)
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? (correct ? const Color(0xFFE5A800) : const Color(0xFF1CB0F6))
        : const Color(0xFFD0D0D0);

    final Color bgColor = selected
        ? (correct
            ? const Color(0xFFFFF2CC)
            : const Color(0xFFE8F7FF))
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.25),
              blurRadius: selected ? 6 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected
                    ? (correct
                        ? const Color(0xFFB07D00)
                        : const Color(0xFF1CB0F6))
                    : Colors.black87,
              ),
            ),
            if (selected && correct) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle,
                  size: 16, color: Color(0xFFE5A800)),
            ],
          ],
        ),
      ),
    );
  }
}