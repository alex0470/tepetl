import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin_widgets.dart';

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
  bool ignoreAccents = true;
  int toleranceIndex = 1;
  bool isSaving = false;

  @override
  void dispose() {
    instruccionCtrl.dispose();
    contenidoCtrl.dispose();
    respuestaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarEjercicio() async {
    if (instruccionCtrl.text.isEmpty ||
        contenidoCtrl.text.isEmpty ||
        respuestaCtrl.text.isEmpty) {
      return;
    }
    setState(() => isSaving = true);
    await CursosService.crearEjercicio(
      widget.cursoId,
      widget.moduloId,
      widget.leccionId,
      EjercicioModel(
        id: '',
        tipoEjercicio: 'leer_y_escribir',
        contenido: contenidoCtrl.text.trim(),
        dificultad: 'BÁSICO',
        respuesta: respuestaCtrl.text.trim(),
        pista: ignoreAccents ? 'Ignorar mayúsculas y acentos' : '',
      ),
    );
    setState(() => isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ManualExerciseScreenShell(
      title: 'Leer y Escribir',
      description:
          'Crea una actividad de lectura donde el alumno repite la frase y escribe la respuesta.',
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
        const SectionHeader(text: 'IMAGEN DE REFERENCIA'),
        Row(
          children: [
            Expanded(
              child: MediaButton(
                text: 'SUBIR ARCHIVO',
                icon: Icons.file_upload_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MediaButton(
                text: 'TOMAR FOTO',
                icon: Icons.camera_alt_outlined,
              ),
            ),
          ],
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
        const SizedBox(height: 20),
        const SectionHeader(text: 'TOLERANCIA DE ESCRITURA (IA)'),
        ToggleButtonGroup(
          options: const ['Permisivo', 'Equilibrado', 'Estricto'],
          selectedIndex: toleranceIndex,
          onChanged: (value) => setState(() => toleranceIndex = value),
        ),
        const SizedBox(height: 20),
        ConsentCheckbox(
          checked: ignoreAccents,
          onChanged: (value) => setState(() => ignoreAccents = value ?? true),
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
  int toleranceIndex = 1;
  int correctImageIndex = 0;
  bool isSaving = false;

  @override
  void dispose() {
    palabraCtrl.dispose();
    objetivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarEjercicio() async {
    if (palabraCtrl.text.isEmpty || objetivoCtrl.text.isEmpty) return;
    setState(() => isSaving = true);
    await CursosService.crearEjercicio(
      widget.cursoId,
      widget.moduloId,
      widget.leccionId,
      EjercicioModel(
        id: '',
        tipoEjercicio: 'imagen_y_palabra',
        contenido: palabraCtrl.text.trim(),
        dificultad: toleranceIndex == 0 ? 'BÁSICO' : 'INTERMEDIO',
        respuesta: objetivoCtrl.text.trim(),
        pista: ['Permisivo', 'Equilibrado', 'Estricto'][toleranceIndex],
      ),
    );
    setState(() => isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ManualExerciseScreenShell(
      title: 'Imágenes y Palabras',
      description:
          'Carga la imagen y define las opciones correctas para la palabra objetivo.',
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
        const SectionHeader(text: 'IMAGEN DE REFERENCIA'),
        Row(
          children: [
            Expanded(
              child: MediaButton(
                text: 'SUBIR ARCHIVO',
                icon: Icons.file_upload_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MediaButton(
                text: 'TOMAR FOTO',
                icon: Icons.camera_alt_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader(text: 'OPCIONES (4 IMÁGENES)'),
        GridView.builder(
          itemCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            return ImageOptionCard(
              index: index,
              isCorrect: index == correctImageIndex,
              onCorrected: () => setState(() => correctImageIndex = index),
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
        const SizedBox(height: 20),
        const SectionHeader(text: 'TOLERANCIA DE ESCRITURA (IA)'),
        ToggleButtonGroup(
          options: const ['Permisivo', 'Equilibrado', 'Estricto'],
          selectedIndex: toleranceIndex,
          onChanged: (value) => setState(() => toleranceIndex = value),
        ),
        const SizedBox(height: 20),
        ConsentCheckbox(checked: true, onChanged: (_) {}),
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

  @override
  void dispose() {
    fraseCtrl.dispose();
    for (final ctrl in opcionControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _guardarEjercicio() async {
    if (fraseCtrl.text.isEmpty || opcionControllers[correctOption].text.isEmpty) {
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
        dificultad: 'BÁSICO',
        respuesta: opcionControllers[correctOption].text.trim(),
        pista: 'Opción correcta ${correctOption + 1}',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(color: AppColors.textoSecundario40, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 30),
            SaveButton(onSave: onSave, isSaving: isSaving),
          ],
        ),
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
