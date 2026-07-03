import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/screens/usuario/widgets/dialog_widgets.dart';
import 'package:tepetl/core/services/perfil_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/usuario/profile_avatar.dart';

class EditarPerfilDialog extends StatefulWidget {
  const EditarPerfilDialog({super.key});

  @override
  State<EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<EditarPerfilDialog> {
  final _nombreCtrl = TextEditingController();

  XFile?     _imagenNueva;
  Uint8List? _imagenBytes;
  String     _fotoUrlActual = '';
  String     _inicialActual = 'U';
  bool       _cargando      = true;
  bool       _guardando     = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosActuales();
  }

  Future<void> _cargarDatosActuales() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _cargando = false); return; }

    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    final data = doc.data() ?? {};

    final nombre = data['nombre'] as String? ?? '';
    final fotoUrl = data['foto_url'] as String? ?? '';

    if (mounted) {
      setState(() {
        _nombreCtrl.text   = nombre;
        _fotoUrlActual     = fotoUrl;
        _inicialActual     = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
        _cargando          = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _imagenNueva = xfile;
      _imagenBytes = bytes;
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      // Subir foto si se escogió una nueva
      if (_imagenNueva != null) {
        await PerfilService.subirFotoPerfil(_imagenNueva!);
      }

      // Guardar nombre
      await PerfilService.actualizarNombre(nombre);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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
        child: _cargando
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
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

                    // ── Avatar ─────────────────────────────────────────────
                    GestureDetector(
                      onTap: _seleccionarImagen,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Preview: imagen nueva > URL actual > iniciales
                          _imagenBytes != null
                              ? CircleAvatar(
                                  radius: 48,
                                  backgroundImage:
                                      MemoryImage(_imagenBytes!),
                                )
                              : ProfileAvatar(
                                  fotoUrl:  _fotoUrlActual,
                                  inicial:  _inicialActual,
                                  radius:   48,
                                  isDark:   isDark,
                                ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AppColors.secundario,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _seleccionarImagen,
                      child: Text(
                        _imagenBytes != null
                            ? 'Imagen seleccionada ✓'
                            : 'Cambiar foto de perfil',
                        style: TextStyle(
                          color: _imagenBytes != null
                              ? Colors.green
                              : AppColors.secundario,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Nombre ─────────────────────────────────────────────
                    CampoTexto(
                      label: 'Nombre completo',
                      controller: _nombreCtrl,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // ── Acciones ───────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.secundario
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardando ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secundario,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _guardando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text('Guardar',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
