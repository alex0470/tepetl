import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/widgets/dialog_widgets.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class NotificacionesDialog extends StatefulWidget {
  const NotificacionesDialog({super.key});

  @override
  State<NotificacionesDialog> createState() => _NotificacionesDialogState();
}

class _NotificacionesDialogState extends State<NotificacionesDialog> {
  bool _push           = true;
  bool _correo         = false;
  bool _racha          = true;
  bool _logros         = true;
  bool _retosSemanales = false;

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
            DialogEncabezado(titulo: 'Notificaciones', icono: Icons.notifications_outlined),
            const SizedBox(height: 20),
            FilaSwitch(
              label: 'Notificaciones Push',
              sub: 'Alertas en tu dispositivo',
              value: _push,
              onChanged: (v) => setState(() => _push = v),
            ),
            FilaSwitch(
              label: 'Correo electrónico',
              sub: 'Resúmenes y novedades',
              value: _correo,
              onChanged: (v) => setState(() => _correo = v),
            ),
            const Divider(height: 24),
            Text(
              'Tipos de alertas',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            FilaSwitch(
              label: 'Racha diaria',
              value: _racha,
              onChanged: (v) => setState(() => _racha = v),
            ),
            FilaSwitch(
              label: 'Logros e insignias',
              value: _logros,
              onChanged: (v) => setState(() => _logros = v),
            ),
            FilaSwitch(
              label: 'Retos semanales',
              value: _retosSemanales,
              onChanged: (v) => setState(() => _retosSemanales = v),
            ),
            const SizedBox(height: 20),
            DialogAcciones(onGuardar: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
