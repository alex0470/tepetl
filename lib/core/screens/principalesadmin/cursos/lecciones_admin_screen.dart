import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/crear_ejercicios_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin_widgets.dart';

class LeccionesAdminScreen extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String moduloTitulo;

  const LeccionesAdminScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.moduloTitulo,
  });

  Future<void> _confirmarEliminar(BuildContext context, String leccionId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar lección?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Se eliminarán la lección y todos sus ejercicios.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoSecundario40))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo1),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CursosService.eliminarLeccion(cursoId, moduloId, leccionId);
    }
  }

  void _showAddLeccionPopup(BuildContext context, int nextOrden) {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nueva Lección',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Label(text: 'Título'),
            AppTextField(controller: tituloCtrl, hint: 'Ej. Saludos básicos'),
            const SizedBox(height: 12),
            const Label(text: 'Descripción'),
            AppTextField(controller: descCtrl, hint: 'Breve descripción...', maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoSecundario40))),
          ElevatedButton(
            onPressed: () async {
              if (tituloCtrl.text.isNotEmpty) {
                await CursosService.crearLeccion(
                  cursoId,
                  moduloId,
                  LeccionModel(
                      id: '',
                      titulo: tituloCtrl.text.trim(),
                      descripcion: descCtrl.text.trim(),
                      orden: nextOrden),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secundario),
            child: const Text('Añadir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(moduloTitulo,
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
      body: StreamBuilder<List<LeccionModel>>(
        stream: CursosService.streamLecciones(cursoId, moduloId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lecciones = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lecciones (${lecciones.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showAddLeccionPopup(context, lecciones.length),
                      icon: const Icon(Icons.add, size: 18, color: AppColors.secundario),
                      label: const Text('AÑADIR',
                          style: TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (lecciones.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay lecciones aún. ¡Añade la primera!',
                        style: TextStyle(color: AppColors.textoSecundario40)),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lecciones.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final leccion = lecciones[index];
                      return LeccionCardAdmin(
                        index: index + 1,
                        titulo: leccion.titulo,
                        descripcion: leccion.descripcion,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CrearEjerciciosScreen(
                              cursoId: cursoId,
                              moduloId: moduloId,
                              moduloTitulo: leccion.titulo,
                              leccionId: leccion.id,
                            ),
                          ),
                        ),
                        onDelete: () => _confirmarEliminar(context, leccion.id),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
