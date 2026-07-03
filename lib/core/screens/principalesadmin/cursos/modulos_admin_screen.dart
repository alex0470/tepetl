import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/lecciones_admin_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin/admin_widgets.dart';

class ModulosAdminScreen extends StatefulWidget {
  final String cursoId;
  final String cursoTitulo;

  const ModulosAdminScreen({super.key, required this.cursoId, required this.cursoTitulo});

  @override
  State<ModulosAdminScreen> createState() => _ModulosAdminScreenState();
}

class _ModulosAdminScreenState extends State<ModulosAdminScreen> {
  late final Stream<List<ModuloModel>> _modulosStream;

  @override
  void initState() {
    super.initState();
    _modulosStream = CursosService.streamModulos(widget.cursoId);
  }

  Future<void> _confirmarEliminar(
      BuildContext context, String moduloId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar módulo?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Se eliminarán el módulo y todas sus lecciones y ejercicios.'),
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
      await CursosService.eliminarModulo(widget.cursoId, moduloId);
    }
  }

  void _showAddModuloPopup(BuildContext context, int nextOrden) {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Módulo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Label(text: 'Título'),
            AppTextField(controller: tituloCtrl, hint: 'Ej. Los Colores'),
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
                await CursosService.crearModulo(
                  widget.cursoId,
                  ModuloModel(
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
        title: Text(widget.cursoTitulo,
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
      body: StreamBuilder<List<ModuloModel>>(
        stream: _modulosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final modulos = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Módulos (${modulos.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showAddModuloPopup(context, modulos.length),
                      icon: const Icon(Icons.add, size: 18, color: AppColors.secundario),
                      label: const Text('AÑADIR',
                          style: TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (modulos.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay módulos aún. ¡Añade el primero!',
                        style: TextStyle(color: AppColors.textoSecundario40)),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: modulos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final modulo = modulos[index];
                      return ModuleCardAdmin(
                        index: index + 1,
                        title: modulo.titulo,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LeccionesAdminScreen(
                              cursoId: widget.cursoId,
                              moduloId: modulo.id,
                              moduloTitulo: modulo.titulo,
                            ),
                          ),
                        ),
                        onDelete: () => _confirmarEliminar(context, modulo.id),
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
