import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/widgets/dialog_widgets.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class IdiomaDialog extends StatefulWidget {
  const IdiomaDialog({super.key});

  @override
  State<IdiomaDialog> createState() => _IdiomaDialogState();
}

class _IdiomaDialogState extends State<IdiomaDialog> {
  String _seleccionado = 'Español (México)';

  static const _idiomas = [
    ('🇲🇽', 'Español (México)'),
    ('🇪🇸', 'Español (España)'),
    ('🇺🇸', 'English (US)'),
    ('🇬🇧', 'English (UK)'),
    ('🇫🇷', 'Français'),
    ('🇩🇪', 'Deutsch'),
    ('🇧🇷', 'Português (BR)'),
    ('🇯🇵', '日本語'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogEncabezado(titulo: 'Idioma de interfaz', icono: Icons.language_outlined),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _idiomas.length,
                itemBuilder: (_, i) {
                  final (flag, nombre) = _idiomas[i];
                  final sel = nombre == _seleccionado;
                  return ListTile(
                    leading: Text(flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      nombre,
                      style: TextStyle(
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                        color: sel
                            ? AppColors.secundario
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: sel
                        ? const Icon(Icons.check_circle, color: AppColors.secundario)
                        : null,
                    onTap: () => setState(() => _seleccionado = nombre),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DialogAcciones(onGuardar: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
