import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin/admin_widgets.dart';

class AddCursoScreen extends StatefulWidget {
  const AddCursoScreen({super.key});

  @override
  State<AddCursoScreen> createState() => _AddCursoScreenState();
}

class _AddCursoScreenState extends State<AddCursoScreen> {
  bool _isPublicado = true;
  bool _isSaving = false;

  // Web-safe image state
  XFile? _xfile;
  Uint8List? _imageBytes;

  String _nivelSeleccionado = 'Básico';

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final List<String> _modulosTitulos = [];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _xfile = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _guardarCurso() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      _mostrarSnackbar('El título es obligatorio');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final cursoId = await CursosService.crearCurso(CursoModel(
        id: '',
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        nivel: _nivelSeleccionado,
        imagenUrl: '',
        publicado: _isPublicado,
        creadoPor: FirebaseAuth.instance.currentUser!.uid,
      ));

      if (_xfile != null) {
        final url =
            await CursosService.subirImagenWeb(_xfile!, cursoId);
        await CursosService.actualizarCurso(cursoId, {'imagen_url': url});
      }

      for (int i = 0; i < _modulosTitulos.length; i++) {
        await CursosService.crearModulo(
          cursoId,
          ModuloModel(
              id: '',
              titulo: _modulosTitulos[i],
              descripcion: '',
              orden: i),
        );
      }

      if (mounted) {
        _mostrarSnackbar(
            _isPublicado ? 'Curso publicado ✅' : 'Borrador guardado');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _mostrarSnackbar('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _guardarBorrador() async {
    setState(() => _isPublicado = false);
    await _guardarCurso();
  }

  void _mostrarSnackbar(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  void _showAddModuloPopup() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Módulo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Label(text: 'Nombre del módulo'),
            AppTextField(controller: ctrl, hint: 'Ej. Los Colores'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(
                    () => _modulosTitulos.add(ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario),
            child: const Text('Añadir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        title: Text('Añadir Nuevo Curso',
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
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _guardarBorrador,
            child: const Text('Guardar Borrador',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = constraints.maxWidth > 600 ? 48.0 : 24.0;
          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                const Label(text: 'Título del Curso'),
                AppTextField(
                    controller: _tituloCtrl,
                    hint: 'Ej. Náhuatl Básico A1'),
                const SizedBox(height: 20),
                _buildVisibilityToggle(),
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
                  onChanged: (v) =>
                      setState(() => _nivelSeleccionado = v!),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Módulos del Curso',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _showAddModuloPopup,
                      icon: const Icon(Icons.add,
                          size: 18, color: AppColors.secundario),
                      label: const Text('AÑADIR',
                          style: TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _modulosTitulos.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) => ModuleCardAdmin(
                    index: index + 1,
                    title: _modulosTitulos[index],
                    onTap: () {},
                    onDelete: () =>
                        setState(() => _modulosTitulos.removeAt(index)),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _guardarCurso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primario,
                      padding:
                          const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : Text(
                            _isPublicado
                                ? 'PUBLICAR CURSO'
                                : 'GUARDAR PRIVADO',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.secundario.withValues(alpha: 0.1)),
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
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
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
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImagen,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.2)),
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined,
                      size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Subir imagen de portada',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 14)),
                ],
              ),
      ),
    );
  }
}