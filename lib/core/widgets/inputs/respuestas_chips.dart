import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

/// Estado visual de cada opción.
enum OptionState { idle, selected, correct, wrong }

/// Chip de opción reutilizable para ejercicios de selección.
///
/// Cambia de color según el estado:
/// - [OptionState.idle]     → fondo neutro del tema.
/// - [OptionState.selected] → azul (sin verificar aún).
/// - [OptionState.correct]  → amarillo/verde (verificado y correcto).
/// - [OptionState.wrong]    → rojo (verificado e incorrecto).
class OpcionChip extends StatelessWidget {
  final String label;
  final OptionState state;
  final VoidCallback? onTap;

  const OpcionChip({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
  });

  // ── Colores según estado ──────────────────────────────────────────────────
  _ChipStyle _resolve(bool isDark, ColorScheme cs) {
    switch (state) {
      case OptionState.selected:
        return _ChipStyle(
          bg: AppColors.azul1.withValues(alpha: 0.2),
          fg: AppColors.azul1,
          shadow: AppColors.azul1.withValues(alpha: 0.2),
        );
      case OptionState.correct:
        return _ChipStyle(
          bg: AppColors.amarillo1.withValues(alpha: 0.2),
          fg: AppColors.amarillo1,
          shadow: AppColors.amarillo1.withValues(alpha: 0.2),
        );
      case OptionState.wrong:
        return _ChipStyle(
          bg: const Color(0xFFFF4B4B).withValues(alpha: 0.2),
          fg: const Color(0xFFFF4B4B),
          shadow: const Color(0xFFFF4B4B).withValues(alpha: 0.2),
        );
      case OptionState.idle:
        return _ChipStyle(
          bg: isDark
              ? AppColors.fondoOscuroSecundario
              : AppColors.fondoSecundario,
          fg: cs.onSurface,
          shadow: Colors.black.withValues(alpha: 0.3),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _resolve(isDark, Theme.of(context).colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: style.bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: style.shadow,
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(3, 3),
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
                color: style.fg,
              ),
            ),
            if (state == OptionState.correct) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.amarillo1,
              ),
            ],
            if (state == OptionState.wrong) ...[
              const SizedBox(width: 6),
              const Icon(Icons.cancel, size: 16, color: Color(0xFFFF4B4B)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipStyle {
  final Color bg, fg, shadow;
  const _ChipStyle({required this.bg, required this.fg, required this.shadow});
}

// ── Helper: grid de opciones (mobile + wide) ──────────────────────────────────

/// Renderiza una lista de opciones en layout automático:
/// - Wide (> 1000px): fila horizontal centrada.
/// - Mobile: primera fila con 2 opciones, resto centrados debajo.
///
/// [options]      : etiquetas de cada opción.
/// [selectedIndex]: índice seleccionado (-1 = ninguno).
/// [correctIndex] : índice de la respuesta correcta.
/// [verified]     : si ya se verificó la respuesta.
/// [onSelect]     : callback con el índice elegido.
class OptionsGrid extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final int correctIndex;
  final bool verified;
  final ValueChanged<int> onSelect;

  const OptionsGrid({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.verified,
    required this.onSelect,
  });

  OptionState _stateOf(int i) {
    if (selectedIndex != i) return OptionState.idle;
    if (!verified) return OptionState.selected;
    return i == correctIndex ? OptionState.correct : OptionState.wrong;
  }

  List<OpcionChip> get _chips => List.generate(
    options.length,
    (i) => OpcionChip(
      label: options[i],
      state: _stateOf(i),
      onTap: verified ? null : () => onSelect(i),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isWide ? _buildWide() : _buildMobile(),
    );
  }

  Widget _buildWide() => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: _chips
        .map(
          (c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: c,
          ),
        )
        .toList(),
  );

  Widget _buildMobile() {
    final chips = _chips;
    // Primera fila: primeros 2; resto: una por fila centrada
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            chips[0],
            if (chips.length > 1) ...[const SizedBox(width: 12), chips[1]],
          ],
        ),
        ...List.generate(chips.length - 2, (i) => i + 2).map(
          (i) => Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [chips[i]],
            ),
          ),
        ),
      ],
    );
  }
}
