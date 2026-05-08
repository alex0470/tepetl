import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/widgets/dialog_widgets.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ── Privacidad y Seguridad ────────────────────────────────────────────────────

class PrivacidadSeguridadDialog extends StatelessWidget {
  const PrivacidadSeguridadDialog({super.key});

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
            DialogEncabezado(titulo: 'Privacidad y Seguridad', icono: Icons.security_outlined),
            const SizedBox(height: 16),
            OpcionSeguridad(
              icono: Icons.lock_outline,
              titulo: 'Cambiar contraseña',
              sub: 'Actualiza tu contraseña de acceso',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const CambiarContrasenaDialog(),
                );
              },
            ),
            OpcionSeguridad(
              icono: Icons.email_outlined,
              titulo: 'Cambiar correo electrónico',
              sub: 'alex@correo.com',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const CambiarCorreoDialog(),
                );
              },
            ),
            OpcionSeguridad(
              icono: Icons.phone_outlined,
              titulo: 'Número de teléfono',
              sub: 'Agrega un número de recuperación',
              onTap: () {},
            ),
            OpcionSeguridad(
              icono: Icons.verified_user_outlined,
              titulo: 'Autenticación en dos pasos',
              sub: 'Aumenta la seguridad de tu cuenta',
              onTap: () {},
            ),
            OpcionSeguridad(
              icono: Icons.delete_outline,
              titulo: 'Eliminar cuenta',
              sub: 'Esta acción es irreversible',
              color: AppColors.rojo1,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cambiar contraseña ────────────────────────────────────────────────────────

class CambiarContrasenaDialog extends StatefulWidget {
  const CambiarContrasenaDialog({super.key});

  @override
  State<CambiarContrasenaDialog> createState() => _CambiarContrasenaDialogState();
}

class _CambiarContrasenaDialogState extends State<CambiarContrasenaDialog> {
  final _actualCtrl    = TextEditingController();
  final _nuevaCtrl     = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _verActual    = false;
  bool _verNueva     = false;
  bool _verConfirmar = false;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

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
            DialogEncabezado(titulo: 'Cambiar contraseña', icono: Icons.lock_outline),
            const SizedBox(height: 20),
            CampoContrasena(
              label: 'Contraseña actual',
              controller: _actualCtrl,
              isDark: isDark,
              visible: _verActual,
              onToggle: () => setState(() => _verActual = !_verActual),
            ),
            const SizedBox(height: 12),
            CampoContrasena(
              label: 'Nueva contraseña',
              controller: _nuevaCtrl,
              isDark: isDark,
              visible: _verNueva,
              onToggle: () => setState(() => _verNueva = !_verNueva),
            ),
            const SizedBox(height: 12),
            CampoContrasena(
              label: 'Confirmar contraseña',
              controller: _confirmarCtrl,
              isDark: isDark,
              visible: _verConfirmar,
              onToggle: () => setState(() => _verConfirmar = !_verConfirmar),
            ),
            const SizedBox(height: 24),
            DialogAcciones(
              onGuardar: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña actualizada correctamente')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cambiar correo ────────────────────────────────────────────────────────────

class CambiarCorreoDialog extends StatefulWidget {
  const CambiarCorreoDialog({super.key});

  @override
  State<CambiarCorreoDialog> createState() => _CambiarCorreoDialogState();
}

class _CambiarCorreoDialogState extends State<CambiarCorreoDialog> {
  final _correoCtrl = TextEditingController(text: 'alex@correo.com');
  final _passCtrl   = TextEditingController();
  bool _verPass = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

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
            DialogEncabezado(titulo: 'Cambiar correo electrónico', icono: Icons.email_outlined),
            const SizedBox(height: 20),
            CampoTexto(
              label: 'Nuevo correo electrónico',
              controller: _correoCtrl,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CampoContrasena(
              label: 'Contraseña actual (para confirmar)',
              controller: _passCtrl,
              isDark: isDark,
              visible: _verPass,
              onToggle: () => setState(() => _verPass = !_verPass),
            ),
            const SizedBox(height: 6),
            Text(
              'Te enviaremos un correo de verificación a la nueva dirección.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 24),
            DialogAcciones(
              onGuardar: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Correo de verificación enviado')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
