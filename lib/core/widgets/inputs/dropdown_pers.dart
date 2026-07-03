import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class DropdownPers<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;
  final IconData prefixIcon;

  const DropdownPers({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textColor  = Theme.of(context).colorScheme.onSurface;
    final menuColor  = Theme.of(context).colorScheme.surface;
    final iconColor  = Theme.of(context).colorScheme.onSurfaceVariant;

    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      decoration: _inputDecoration(
        prefixIcon: prefixIcon,
        iconColor: iconColor,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: iconColor,
      ),
      style: TextStyle(fontSize: 14, color: textColor),
      dropdownColor: menuColor,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(label(e)),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _inputDecoration({
    required IconData prefixIcon,
    required Color iconColor,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        prefixIcon,
        color: iconColor,
        size: 20,
      ),
      filled: true,
      fillColor: AppColors.secundario.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.secundario,
          width: 1.2,
        ),
      ),
    );
  }
}