import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/crear_ejercicios_manuales.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/generar_ia_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin/admin_widgets.dart';

class CrearEjerciciosScreen extends StatefulWidget {
  final String cursoId;
  final String moduloId;
  final String moduloTitulo;
  final String leccionId;

  const CrearEjerciciosScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.moduloTitulo,
    required this.leccionId,
  });

  @override
  State<CrearEjerciciosScreen> createState() => _CrearEjerciciosScreenState();
}

class _CrearEjerciciosScreenState extends State<CrearEjerciciosScreen> {
  late final TextEditingController _moduloNameController;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    _moduloNameController = TextEditingController(text: widget.moduloTitulo);
  }

  @override
  void dispose() {
    _moduloNameController.dispose();
    super.dispose();
  }

  Future<void> _guardarNombreModulo() async {
    setState(() => _isSavingName = true);
    await CursosService.actualizarLeccion(widget.cursoId, widget.moduloId, widget.leccionId,
        {'titulo': _moduloNameController.text.trim()});
    setState(() => _isSavingName = false);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lección actualizada')));
    }
  }

  void _showNewEjercicioPopup(BuildContext context, String leccionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewEjercicioActionCards(
        cursoId: widget.cursoId,
        moduloId: widget.moduloId,
        leccionId: leccionId,
      ),
    );
  }

  Future<void> _confirmarEliminarEjercicio(
      String leccionId, String ejercicioId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Deseas eliminar el ejercicio?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo1),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CursosService.eliminarEjercicio(
          widget.cursoId, widget.moduloId, leccionId, ejercicioId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        title: Text('Editar Lección',
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
      body: StreamBuilder<List<EjercicioModel>>(
        stream: CursosService.streamEjerciciosDeLeccion(
            widget.cursoId, widget.moduloId, widget.leccionId),
        builder: (context, ejSnap) {
          final ejercicios = ejSnap.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Label(text: 'Nombre de la Lección'),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                          controller: _moduloNameController,
                          hint: 'Ej. Los Colores',
                          icon: Icons.edit_outlined),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isSavingName ? null : _guardarNombreModulo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secundario,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSavingName
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_outlined, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ejercicios (${ejercicios.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showNewEjercicioPopup(context, widget.leccionId),
                      icon: const Icon(Icons.add, size: 18, color: AppColors.secundario),
                      label: const Text('AÑADIR',
                          style: TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (ejercicios.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No hay ejercicios aún.',
                        style: TextStyle(color: AppColors.textoSecundario40)),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ejercicios.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ej = ejercicios[index];
                      return EjercicioCardAdmin(
                        contenido: ej.contenido,
                        tipo: ej.tipoEjercicio,
                        dificultad: ej.dificultad,
                        respuesta: ej.respuesta,
                        pista: ej.pista,
                        onEdit: () {},
                        onDelete: () => _confirmarEliminarEjercicio(
                            widget.leccionId, ej.id),
                      );
                    },
                  ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NewEjercicioActionCards extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const NewEjercicioActionCards({
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final activityTypes = [
      {'title': 'Leer y Escribir', 'icon': Icons.edit_note_outlined},
      {'title': 'Imagen y Palabra', 'icon': Icons.image_outlined},
      {'title': 'Completar Frase', 'icon': Icons.text_fields_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textoSecundario40,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Nuevo Ejercicio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Selecciona el tipo de actividad para tu módulo',
              style: TextStyle(color: AppColors.textoSecundario40, fontSize: 14)),
          const SizedBox(height: 24),
          ...activityTypes.map((type) => ActivityActionCard(
                title: type['title'] as String,
                icon: type['icon'] as IconData,
                cursoId: cursoId,
                moduloId: moduloId,
                leccionId: leccionId,
              )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ActivityActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const ActivityActionCard({
    required this.title,
    required this.icon,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(26)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secundario),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Widget destScreen;
                    if (title == 'Leer y Escribir') {
                      destScreen = CrearLeerYEscribirScreen(
                          cursoId: cursoId, moduloId: moduloId, leccionId: leccionId);
                    } else if (title == 'Imagen y Palabra') {
                      destScreen = CrearImagenYPalabraScreen(
                          cursoId: cursoId, moduloId: moduloId, leccionId: leccionId);
                    } else {
                      destScreen = CrearCompletarFraseScreen(
                          cursoId: cursoId, moduloId: moduloId, leccionId: leccionId);
                    }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => destScreen));
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textoSecundario40),
                  label: const Text('Manualmente', style: TextStyle(color: AppColors.textoSecundario40)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha(30)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => GenerarConIAScreen(
                                  cursoId: cursoId,
                                  moduloId: moduloId,
                                  leccionId: leccionId,
                                )));
                  },
                  icon: Icon(Icons.auto_awesome_outlined,
                      size: 16, color: AppColors.secundario),
                  label: Text('Generar con IA',
                      style: TextStyle(color: AppColors.secundario)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario.withAlpha(40),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
