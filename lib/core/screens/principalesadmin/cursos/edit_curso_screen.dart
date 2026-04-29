import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/modulos_admin_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin_widgets.dart';

class EditCursoScreen extends StatefulWidget {
  final CursoModel curso;

  const EditCursoScreen({super.key, required this.curso});

  @override
  State<EditCursoScreen> createState() => _EditCursoScreenState();
}

class _EditCursoScreenState extends State<EditCursoScreen> {
  late bool _isPublicado;
  late String _nivelSeleccionado;
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  File? _imagenLocal;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isPublicado = widget.curso.publicado;
    final nivelesValidos = ['Básico', 'Básico+', 'Intermedio'];
    _nivelSeleccionado = nivelesValidos.contains(widget.curso.nivel)
        ? widget.curso.nivel
        : 'Básico';
    _tituloCtrl = TextEditingController(text: widget.curso.titulo);
    _descripcionCtrl = TextEditingController(text: widget.curso.descripcion);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagenLocal = File(picked.path));
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      String imagenUrl = widget.curso.imagenUrl;
      if (_imagenLocal != null) {
        imagenUrl = await CursosService.subirImagen(_imagenLocal!, widget.curso.id);
      }
      await CursosService.actualizarCurso(widget.curso.id, {
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'nivel': _nivelSeleccionado,
        'publicado': _isPublicado,
        'imagen_url': imagenUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Curso actualizado ✅')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Curso',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImagen,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                ),
                child: _imagenLocal != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_imagenLocal!, fit: BoxFit.cover))
                    : widget.curso.imagenUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(widget.curso.imagenUrl,
                                fit: BoxFit.cover))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 40, color: AppColors.textoSecundario40),
                              const SizedBox(height: 8),
                              Text('Cambiar imagen de portada',
                                  style: TextStyle(
                                      color: AppColors.textoSecundario40, fontSize: 14)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            const Label(text: 'Título del Curso'),
            AppTextField(controller: _tituloCtrl, hint: 'Ej. Náhuatl Básico A1'),
            const SizedBox(height: 20),
            const Label(text: 'Descripción'),
            AppTextField(
                controller: _descripcionCtrl,
                hint: 'Describe brevemente el curso...',
                maxLines: 3),
            const SizedBox(height: 20),
            const Label(text: 'Nivel'),
            NivelDropdown(
              value: _nivelSeleccionado,
              onChanged: (v) => setState(() => _nivelSeleccionado = v!),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secundario.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                      _isPublicado
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.secundario),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Visibilidad',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                            _isPublicado
                                ? 'Público para estudiantes'
                                : 'Privado (Borrador)',
                            style: TextStyle(
                                fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublicado,
                    activeThumbColor: AppColors.secundario,
                    onChanged: (val) => setState(() => _isPublicado = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ModulosAdminScreen(
                          cursoId: widget.curso.id,
                          cursoTitulo: widget.curso.titulo))),
              icon: const Icon(Icons.view_module_outlined,
                  color: AppColors.secundario),
              label: const Text('Gestionar Módulos',
                  style: TextStyle(color: AppColors.secundario)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.secundario),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primario,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('GUARDAR CAMBIOS',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
