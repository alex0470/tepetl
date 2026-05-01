import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/add_curso_screen.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/edit_curso_screen.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/lecciones_admin_screen.dart';
import 'package:tepetl/core/screens/principalesadmin/cursos/modulos_admin_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin/admin_widgets.dart';

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

  Future<void> _confirmarEliminar(
    BuildContext context,
    CursoModel curso,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar curso?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Se eliminarán permanentemente "${curso.titulo}" y todos sus módulos, lecciones y ejercicios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo1),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CursosService.eliminarCurso(curso.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Curso eliminado')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCursoScreen()),
        ),
        backgroundColor: AppColors.secundario,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestiona Cursos',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cursos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
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
                    .map(
                      (nivel) => Padding(
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
                          onSelected: (_) =>
                              setState(() => selectedNivel = nivel),
                        ),
                      ),
                    )
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
                          builder: (_) => EditCursoScreen(curso: curso),
                        ),
                      ),
                      onEliminar: () => _confirmarEliminar(context, curso),
                      onVerModulos: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CursoDetalleAdminScreen(
                            cursoId: curso.id,
                            cursoTitulo: curso.titulo,
                          ),
                        ),
                      ),
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

class CursoDetalleAdminScreen extends StatelessWidget {
  final String cursoId;
  final String cursoTitulo;

  const CursoDetalleAdminScreen({
    super.key,
    required this.cursoId,
    required this.cursoTitulo,
  });

  Future<List<int>> _fetchStats() {
    return Future.wait([
      CursosService.contarModulos(cursoId),
      CursosService.contarLecciones(cursoId),
      CursosService.contarEjercicios(cursoId),
      CursosService.contarUsuariosSuscritos(cursoId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cursoTitulo,
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
              'Resumen del curso',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<int>>(
              future: _fetchStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final stats = snapshot.data ?? [0, 0, 0, 0];
                return Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    _StatCard(label: 'Módulos', value: '${stats[0]}'),
                    _StatCard(label: 'Lecciones', value: '${stats[1]}'),
                    _StatCard(label: 'Ejercicios', value: '${stats[2]}'),
                    _StatCard(label: 'Suscritos', value: '${stats[3]}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Módulos',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<ModuloModel>>(
              stream: CursosService.streamModulos(cursoId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final modulos = snapshot.data ?? [];
                if (modulos.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No hay módulos aún. Añade el primero.'),
                  );
                }
                return ListView.separated(
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
                            cursoId: cursoId,
                            moduloId: modulo.id,
                            moduloTitulo: modulo.titulo,
                          ),
                        ),
                      ),
                      onDelete: () async {},
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ModulosAdminScreen(
                    cursoId: cursoId,
                    cursoTitulo: cursoTitulo,
                  ),
                ),
              ),
              icon: const Icon(Icons.manage_search),
              label: const Text('Administrar módulos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textoSecundario40,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secundario,
            ),
          ),
        ],
      ),
    );
  }
}
