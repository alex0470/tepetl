import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/widgets/dialog_widgets.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class EditarPerfilDialog extends StatefulWidget {
  const EditarPerfilDialog({super.key});

  @override
  State<EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<EditarPerfilDialog> {
  final _nombreCtrl = TextEditingController(text: 'Alex Alex Alex');
  final _apodoCtrl  = TextEditingController(text: 'Aprendiz Intermedio');

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apodoCtrl.dispose();
    super.dispose();
  }

  void _seleccionarImagen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conecta image_picker para seleccionar fotos del dispositivo.'),
        duration: Duration(seconds: 3),
      ),
    );
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: isDark ? AppColors.fondoOscuro : AppColors.fondoSecundario,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: AppColors.primario,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: GestureDetector(
                      onTap: _seleccionarImagen,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AppColors.secundario,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _seleccionarImagen,
                child: Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(
                    color: AppColors.secundario,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(label: 'Nombre completo', controller: _nombreCtrl, isDark: isDark),
              const SizedBox(height: 12),
              CampoTexto(label: 'Apodo / Nivel', controller: _apodoCtrl, isDark: isDark),
              const SizedBox(height: 24),
              DialogAcciones(
                onGuardar: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
