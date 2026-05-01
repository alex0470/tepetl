import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin/admin_widgets.dart';

Future<XFile?> _pickImageSafe({bool fromCamera = false}) async {
  final picker = ImagePicker();
  // Camera not supported on Web → fall back to gallery
  final source = (!kIsWeb && fromCamera)
      ? ImageSource.camera
      : ImageSource.gallery;
  return picker.pickImage(source: source);
}

class CrearLeerYEscribirScreen extends StatefulWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const CrearLeerYEscribirScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  State<CrearLeerYEscribirScreen> createState() =>
      _CrearLeerYEscribirScreenState();
}

class _CrearLeerYEscribirScreenState extends State<CrearLeerYEscribirScreen> {
  final instruccionCtrl = TextEditingController();
  final contenidoCtrl = TextEditingController();
  final respuestaCtrl = TextEditingController();
  bool isSaving = false;
  PalabraModel? selectedPalabra;
  XFile? _xfile;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    instruccionCtrl.dispose();
    contenidoCtrl.dispose();
    respuestaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImagen({bool fromCamera = false}) async {
    final picked = await _pickImageSafe(fromCamera: fromCamera);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _xfile = picked;
        _imageBytes = bytes;
        selectedPalabra = null;
      });
    }
  }

  void _showPalabrasSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PalabrasSelector(
        onSelect: (palabra) {
          setState(() {
            selectedPalabra = palabra;
            _xfile = null;
            _imageBytes = null;
            contenidoCtrl.text = palabra.palabraNahuatl;
            respuestaCtrl.text = palabra.traduccionEspanol;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _guardarEjercicio() async {
    if (instruccionCtrl.text.isEmpty ||
        contenidoCtrl.text.isEmpty ||
        respuestaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa instrucción, texto y respuesta'),
        ),
      );
      return;
    }
    setState(() => isSaving = true);
    try {
      String imagenUrl = selectedPalabra?.imagenUrl ?? '';
      if (_xfile != null) {
        imagenUrl = await CursosService.subirImagenEjercicioWeb(
          _xfile!,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      await CursosService.crearEjercicio(
        widget.cursoId,
        widget.moduloId,
        widget.leccionId,
        EjercicioModel(
          id: '',
          tipoEjercicio: 'leer_y_escribir',
          contenido: contenidoCtrl.text.trim(),
          dificultad: selectedPalabra?.dificultad.toUpperCase() ?? 'BÁSICO',
          respuesta: respuestaCtrl.text.trim(),
          pista: selectedPalabra?.categoria ?? '',
          categoria: selectedPalabra?.categoria ?? '',
          vocabId: selectedPalabra?.id ?? '',
          imagenUrl: imagenUrl,
          opciones: [],
          creadoPor: FirebaseAuth.instance.currentUser!.uid,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el ejercicio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManualExerciseScreenShell(
      title: 'Leer y Escribir',
      description:
          'Crea una actividad donde el alumno lee la frase y escribe la respuesta.',
      buttonLabel: 'Guardar Ejercicio',
      onSave: _guardarEjercicio,
      isSaving: isSaving,
      children: [
        const SectionHeader(text: 'INSTRUCCIÓN'),
        AppTextField(
          controller: instruccionCtrl,
          hint: 'Leer y repite la frase',
          icon: Icons.edit_note_outlined,
        ),
        const SizedBox(height: 20),
        const SectionHeader(text: 'IMAGEN DE REFERENCIA (OPCIONAL)'),

        // Preview when image is selected
        if (_imageBytes != null)
          _ImagePreview(
            imageBytes: _imageBytes!,
            label: 'Imagen personalizada',
            onClear: () => setState(() {
              _xfile = null;
              _imageBytes = null;
            }),
          )
        else if (selectedPalabra != null)
          _PalabraChip(
            palabra: selectedPalabra!,
            onClear: () => setState(() => selectedPalabra = null),
          )
        else
          _ImagePickerButtons(
            onGallery: () => _pickImagen(),
            onCamera: () => _pickImagen(fromCamera: true),
            onPalabras: _showPalabrasSelector,
          ),

        const SizedBox(height: 24),
        const SectionHeader(text: 'TEXTO OBJETIVO (NÁHUATL)'),
        AppTextField(
          controller: contenidoCtrl,
          hint: '¿Quén tlenim?',
          icon: Icons.language_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        const SectionHeader(text: 'RESPUESTA CORRECTA'),
        AppTextField(
          controller: respuestaCtrl,
          hint: 'Niltze, ¿quién tiene?',
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }
}

class CrearImagenYPalabraScreen extends StatefulWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const CrearImagenYPalabraScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  State<CrearImagenYPalabraScreen> createState() =>
      _CrearImagenYPalabraScreenState();
}

class _CrearImagenYPalabraScreenState extends State<CrearImagenYPalabraScreen> {
  final palabraCtrl = TextEditingController();
  final objetivoCtrl = TextEditingController();
  int correctImageIndex = 0;
  bool isSaving = false;
  PalabraModel? selectedPalabra;

  XFile? _xfile;
  Uint8List? _imageBytes;

  final List<XFile?> _optionXFiles = List.filled(4, null);
  final List<Uint8List?> _optionBytes = List.filled(4, null);
  final List<TextEditingController> _altControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    palabraCtrl.dispose();
    objetivoCtrl.dispose();
    for (final c in _altControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMainImagen({bool fromCamera = false}) async {
    final picked = await _pickImageSafe(fromCamera: fromCamera);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _xfile = picked;
        _imageBytes = bytes;
        selectedPalabra = null;
      });
    }
  }

  Future<void> _pickOptionImagen(int index) async {
    final picked = await _pickImageSafe();
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _optionXFiles[index] = picked;
        _optionBytes[index] = bytes;
      });
    }
  }

  void _showPalabrasSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PalabrasSelector(
        onSelect: (palabra) {
          setState(() {
            selectedPalabra = palabra;
            _xfile = null;
            _imageBytes = null;
            palabraCtrl.text = palabra.palabraNahuatl;
            objetivoCtrl.text = palabra.traduccionEspanol;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _guardarEjercicio() async {
    if (palabraCtrl.text.isEmpty || objetivoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa la palabra y el texto objetivo'),
        ),
      );
      return;
    }
    setState(() => isSaving = true);
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;

      String imagenUrl = selectedPalabra?.imagenUrl ?? '';
      if (_xfile != null) {
        imagenUrl = await CursosService.subirImagenEjercicioWeb(
          _xfile!,
          '${ts}_main',
        );
      }

      final List<Map<String, String>> opciones = [];
      for (int i = 0; i < 4; i++) {
        String optUrl = '';
        if (_optionXFiles[i] != null) {
          optUrl = await CursosService.subirImagenEjercicioWeb(
            _optionXFiles[i]!,
            '${ts}_opt$i',
          );
        }
        opciones.add({
          'imagenUrl': optUrl,
          'texto': _altControllers[i].text.trim(),
          'esCorrecta': i == correctImageIndex ? 'true' : 'false',
        });
      }

      final dificultad = selectedPalabra?.dificultad.toUpperCase() ?? 'BÁSICO';
      await CursosService.crearEjercicio(
        widget.cursoId,
        widget.moduloId,
        widget.leccionId,
        EjercicioModel(
          id: '',
          tipoEjercicio: 'imagen_y_palabra',
          contenido: palabraCtrl.text.trim(),
          dificultad: dificultad,
          respuesta: objetivoCtrl.text.trim(),
          pista: selectedPalabra?.categoria ?? '',
          categoria: selectedPalabra?.categoria ?? '',
          vocabId: selectedPalabra?.id ?? '',
          imagenUrl: imagenUrl,
          opciones: opciones,
          creadoPor: FirebaseAuth.instance.currentUser!.uid,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el ejercicio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManualExerciseScreenShell(
      title: 'Imágenes y Palabras',
      description:
          'Carga la imagen principal y define las 4 opciones. Marca cuál es la correcta.',
      buttonLabel: 'Guardar Ejercicio',
      onSave: _guardarEjercicio,
      isSaving: isSaving,
      children: [
        const SectionHeader(text: 'PALABRA / CONCEPTO'),
        AppTextField(
          controller: palabraCtrl,
          hint: 'Tepetl',
          icon: Icons.label_outlined,
        ),
        const SizedBox(height: 20),
        const SectionHeader(text: 'IMAGEN PRINCIPAL DE REFERENCIA'),
        if (_imageBytes != null)
          _ImagePreview(
            imageBytes: _imageBytes!,
            label: 'Imagen personalizada',
            onClear: () => setState(() {
              _xfile = null;
              _imageBytes = null;
            }),
          )
        else if (selectedPalabra != null)
          _PalabraChip(
            palabra: selectedPalabra!,
            onClear: () => setState(() => selectedPalabra = null),
          )
        else
          _ImagePickerButtons(
            onGallery: () => _pickMainImagen(),
            onCamera: () => _pickMainImagen(fromCamera: true),
            onPalabras: _showPalabrasSelector,
          ),

        const SizedBox(height: 24),
        const SectionHeader(text: 'OPCIONES (4 IMÁGENES)'),
        const Text(
          'Toca ✓ para marcar la imagen correcta',
          style: TextStyle(fontSize: 12, color: AppColors.textoSecundario40),
        ),
        const SizedBox(height: 12),
        // Responsive grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 500 ? 4 : 2;
            return GridView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                return _ImageOptionCardStateful(
                  index: index,
                  isCorrect: index == correctImageIndex,
                  imageBytes: _optionBytes[index],
                  altController: _altControllers[index],
                  onCorrected: () => setState(() => correctImageIndex = index),
                  onPickImage: () => _pickOptionImagen(index),
                );
              },
            );
          },
        ),

        const SizedBox(height: 24),
        const SectionHeader(text: 'TEXTO OBJETIVO (NÁHUATL)'),
        AppTextField(
          controller: objetivoCtrl,
          hint: '¿Quén tlenim?',
          icon: Icons.language_outlined,
        ),
      ],
    );
  }
}

class CrearCompletarFraseScreen extends StatefulWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const CrearCompletarFraseScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  State<CrearCompletarFraseScreen> createState() =>
      _CrearCompletarFraseScreenState();
}

class _CrearCompletarFraseScreenState extends State<CrearCompletarFraseScreen> {
  final fraseCtrl = TextEditingController();
  final opcionControllers = List.generate(4, (_) => TextEditingController());
  int correctOption = 0;
  bool isSaving = false;
  PalabraModel? selectedPalabra;

  @override
  void dispose() {
    fraseCtrl.dispose();
    for (final ctrl in opcionControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _showPalabrasSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PalabrasSelector(
        onSelect: (palabra) {
          setState(() {
            selectedPalabra = palabra;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _guardarEjercicio() async {
    if (fraseCtrl.text.isEmpty ||
        opcionControllers[correctOption].text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe la frase y la opción correcta')),
      );
      return;
    }
    setState(() => isSaving = true);
    await CursosService.crearEjercicio(
      widget.cursoId,
      widget.moduloId,
      widget.leccionId,
      EjercicioModel(
        id: '',
        tipoEjercicio: 'completar_frase',
        contenido: fraseCtrl.text.trim(),
        dificultad: selectedPalabra?.dificultad.toUpperCase() ?? 'BÁSICO',
        respuesta: opcionControllers[correctOption].text.trim(),
        pista: selectedPalabra?.categoria ??
            'Opción correcta ${correctOption + 1}',
        categoria: selectedPalabra?.categoria ?? '',
        vocabId: selectedPalabra?.id ?? '',
        opciones: opcionControllers
            .map((ctrl) => ctrl.text.trim())
            .where((text) => text.isNotEmpty)
            .toList(),
        creadoPor: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
    setState(() => isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ManualExerciseScreenShell(
      title: 'Completar Frase',
      description:
          'Crea una frase con espacios faltantes y marca la opción correcta.',
      buttonLabel: 'Guardar Ejercicio',
      onSave: _guardarEjercicio,
      isSaving: isSaving,
      children: [
        const SectionHeader(text: 'FRASE'),
        AppTextField(
          controller: fraseCtrl,
          hint: 'La __ emplumada es un dios...',
          icon: Icons.text_fields_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        const SectionHeader(text: 'PALABRA INICIAL'),
        if (selectedPalabra != null)
          _PalabraChip(
            palabra: selectedPalabra!,
            onClear: () => setState(() => selectedPalabra = null),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPalabrasSelector(),
              icon: const Icon(Icons.library_books_outlined),
              label: const Text('Seleccionar palabra inicial'),
            ),
          ),
        const SizedBox(height: 20),
        const SectionHeader(text: 'OPCIONES'),
        ...List.generate(
          opcionControllers.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OptionFraseCard(
              index: index,
              isCorrect: index == correctOption,
              groupValue: correctOption,
              onChanged: (value) => setState(() => correctOption = value ?? 0),
              controller: opcionControllers[index],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ConsentCheckbox(checked: true, onChanged: (_) {}),
      ],
    );
  }
}

class ManualExerciseScreenShell extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;
  final String buttonLabel;
  final bool isSaving;
  final VoidCallback onSave;

  const ManualExerciseScreenShell({
    required this.title,
    required this.description,
    required this.children,
    required this.buttonLabel,
    required this.isSaving,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = constraints.maxWidth > 600 ? 48.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textoSecundario40,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ...children,
                const SizedBox(height: 30),
                SaveButton(onSave: onSave, isSaving: isSaving),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class ToggleButtonGroup extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ToggleButtonGroup({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: Container(
              margin: EdgeInsets.only(
                right: index < options.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.secundario.withAlpha(38)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.secundario
                      : Theme.of(context).colorScheme.outline.withAlpha(31),
                ),
              ),
              child: Center(
                child: Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? AppColors.secundario : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class PalabrasSelector extends StatefulWidget {
  final Function(PalabraModel) onSelect;
  const PalabrasSelector({required this.onSelect, super.key});

  @override
  State<PalabrasSelector> createState() => _PalabrasSelectorState();
}

class _PalabrasSelectorState extends State<PalabrasSelector> {
  String selectedDificultad = 'Básico';
  final dificultades = ['Básico', 'Básico+', 'Intermedio'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Seleccionar Palabra',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ToggleButtonGroup(
            options: dificultades,
            selectedIndex: dificultades.indexOf(selectedDificultad),
            onChanged: (i) =>
                setState(() => selectedDificultad = dificultades[i]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<PalabraModel>>(
              future: CursosService.getPalabrasByDificultad(selectedDificultad),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay palabras disponibles'),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final palabra = snapshot.data![index];
                    return ListTile(
                      leading: palabra.imagenUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                palabra.imagenUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(
                        palabra.palabraNahuatl,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${palabra.traduccionEspanol} · ${palabra.categoria}',
                      ),
                      onTap: () => widget.onSelect(palabra),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List imageBytes;
  final String label;
  final VoidCallback onClear;

  const _ImagePreview({
    required this.imageBytes,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secundario.withAlpha(60)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.memory(
              imageBytes,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.secundario,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: AppColors.rojo1,
                  ),
                  onPressed: onClear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PalabraChip extends StatelessWidget {
  final PalabraModel palabra;
  final VoidCallback onClear;

  const _PalabraChip({required this.palabra, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secundario.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secundario.withAlpha(80)),
      ),
      child: Row(
        children: [
          if (palabra.imagenUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                palabra.imagenUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  palabra.palabraNahuatl,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  palabra.traduccionEspanol,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSecundario40,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 18, color: AppColors.rojo1),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _ImagePickerButtons extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onPalabras;

  const _ImagePickerButtons({
    required this.onGallery,
    required this.onCamera,
    required this.onPalabras,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MediaButton(
                text: 'SUBIR ARCHIVO',
                icon: Icons.file_upload_outlined,
                onPressed: onGallery,
              ),
            ),
            if (!kIsWeb) ...[
              const SizedBox(width: 12),
              Expanded(
                child: MediaButton(
                  text: 'TOMAR FOTO',
                  icon: Icons.camera_alt_outlined,
                  onPressed: onCamera,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        MediaButton(
          text: 'SELECCIONAR DE PALABRAS',
          icon: Icons.library_books_outlined,
          onPressed: onPalabras,
        ),
      ],
    );
  }
}

class _ImageOptionCardStateful extends StatelessWidget {
  final int index;
  final bool isCorrect;
  final Uint8List? imageBytes;
  final TextEditingController altController;
  final VoidCallback onCorrected;
  final VoidCallback onPickImage;

  const _ImageOptionCardStateful({
    required this.index,
    required this.isCorrect,
    required this.imageBytes,
    required this.altController,
    required this.onCorrected,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? AppColors.secundario
              : AppColors.textoSecundario40.withAlpha(60),
          width: isCorrect ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPickImage,
                  child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppColors.secundario,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Imagen ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textoSecundario40,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: altController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Texto alt...',
                  hintStyle: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoSecundario40,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.textoSecundario40.withAlpha(60),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.textoSecundario40.withAlpha(60),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Correct marker
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onCorrected,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.secundario
                      : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.secundario
                        : Theme.of(context).colorScheme.outline.withAlpha(80),
                  ),
                ),
                child: isCorrect
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
