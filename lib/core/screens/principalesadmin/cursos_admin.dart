import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/add_curso_screen.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/edit_curso_screen.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/modulos_admin_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin_widgets.dart';

class CursosAdminScreen extends StatefulWidget {
  const CursosAdminScreen({super.key});

  @override
  State<CursosAdminScreen> createState() => _CursosAdminScreenState();
}

class _CursosAdminScreenState extends State<CursosAdminScreen> {
  String selectedNivel = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CursoModel> _filtrar(List<CursoModel> cursos) {
    return cursos.where((c) {
      final matchSearch = c.titulo.toLowerCase().contains(_searchQuery);
      final matchNivel = selectedNivel == 'Todos' || c.nivel == selectedNivel;
      return matchSearch && matchNivel;
    }).toList();
  }

  Future<void> _confirmarEliminar(BuildContext context, CursoModel curso) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar curso?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Se eliminarán permanentemente "${curso.titulo}" y todos sus módulos, lecciones y ejercicios.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo1),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CursosService.eliminarCurso(curso.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Curso eliminado')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddCursoScreen())),
        backgroundColor: AppColors.secundario,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestiona Cursos',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cursos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Básico', 'Básico+', 'Intermedio']
                    .map((nivel) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(nivel),
                            selected: selectedNivel == nivel,
                            selectedColor: AppColors.secundario,
                            labelStyle: TextStyle(
                              color: selectedNivel == nivel
                                  ? Colors.white
                                  : AppColors.textoSecundario40,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) => setState(() => selectedNivel = nivel),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 25),
            StreamBuilder<List<CursoModel>>(
              stream: CursosService.streamCursos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final cursos = _filtrar(snapshot.data ?? []);
                if (cursos.isEmpty) {
                  return const Center(child: Text('No se encontraron cursos'));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cursos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final curso = cursos[index];
                    return CursoAdminCard(
                      curso: curso,
                      onEditar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditCursoScreen(curso: curso))),
                      onEliminar: () => _confirmarEliminar(context, curso),
                      onVerModulos: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ModulosAdminScreen(
                                  cursoId: curso.id, cursoTitulo: curso.titulo))),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
