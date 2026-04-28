import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tepetl/core/theme/app_colors.dart';

// ─── MODELOS ──────────────────────────────────────────────────────────────────

class CursoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String nivel;
  final String imagenUrl;
  final bool publicado;

  CursoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.nivel,
    required this.imagenUrl,
    required this.publicado,
  });

  factory CursoModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CursoModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      nivel: data['nivel'] ?? '',
      imagenUrl: data['imagen_url'] ?? '',
      publicado: data['publicado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'nivel': nivel,
        'imagen_url': imagenUrl,
        'publicado': publicado,
      };
}

class ModuloModel {
  final String id;
  final String titulo;
  final String descripcion;
  final int orden;

  ModuloModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
  });

  factory ModuloModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModuloModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      orden: data['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'orden': orden,
      };
}

class LeccionModel {
  final String id;
  final String titulo;
  final String descripcion;
  final int orden;

  LeccionModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
  });

  factory LeccionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeccionModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      orden: data['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'orden': orden,
      };
}

class EjercicioModel {
  final String id;
  final String tipoEjercicio;
  final String contenido; // texto de la instrucción/pregunta
  final String dificultad;
  final String respuesta;
  final String pista;
  final String categoria;
  final String vocabId;
  final List<dynamic> opciones;

  EjercicioModel({
    required this.id,
    required this.tipoEjercicio,
    required this.contenido,
    required this.dificultad,
    required this.respuesta,
    required this.pista,
    this.categoria = '',
    this.vocabId = '',
    this.opciones = const [],
  });

  factory EjercicioModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EjercicioModel(
      id: doc.id,
      tipoEjercicio: data['tipo_ejercicio'] ?? '',
      contenido: data['contenido']?.toString() ?? '',
      dificultad: data['dificultad'] ?? '',
      respuesta: data['respuesta'] ?? '',
      pista: data['pista'] ?? '',
      categoria: data['categoria'] ?? '',
      vocabId: data['vocab_id'] ?? '',
      opciones: data['opciones'] ?? [],
    );
  }

  Map<String, dynamic> toMap() => {
        'tipo_ejercicio': tipoEjercicio,
        'contenido': contenido,
        'dificultad': dificultad,
        'respuesta': respuesta,
        'pista': pista,
        'categoria': categoria,
        'vocab_id': vocabId,
        'opciones': opciones,
      };
}

// ─── SERVICIO FIREBASE ────────────────────────────────────────────────────────

class CursosService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // ── CURSOS ──────────────────────────────────────────────────────────────────

  static Stream<List<CursoModel>> streamCursos() {
    return _db.collection('cursos').snapshots().map(
          (snap) => snap.docs.map(CursoModel.fromDoc).toList(),
        );
  }

  static Future<String> crearCurso(CursoModel curso) async {
    final ref = await _db.collection('cursos').add(curso.toMap());
    return ref.id;
  }

  static Future<void> actualizarCurso(String cursoId, Map<String, dynamic> data) {
    return _db.collection('cursos').doc(cursoId).update(data);
  }

  static Future<void> eliminarCurso(String cursoId) async {
    // Elimina subcolecciones en cascada: módulos → lecciones → ejercicios
    final modulos = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .get();
    for (final modDoc in modulos.docs) {
      await eliminarModulo(cursoId, modDoc.id);
    }
    await _db.collection('cursos').doc(cursoId).delete();
  }

  static Future<String> subirImagen(File imagen, String cursoId) async {
    final ref = _storage.ref('cursos/$cursoId/portada.jpg');
    await ref.putFile(imagen);
    return await ref.getDownloadURL();
  }

  // ── MÓDULOS ─────────────────────────────────────────────────────────────────

  static Stream<List<ModuloModel>> streamModulos(String cursoId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs.map(ModuloModel.fromDoc).toList());
  }

  static Future<void> crearModulo(String cursoId, ModuloModel modulo) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .add(modulo.toMap());
  }

  static Future<void> actualizarModulo(
      String cursoId, String moduloId, Map<String, dynamic> data) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .update(data);
  }

  static Future<void> eliminarModulo(String cursoId, String moduloId) async {
    final lecciones = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .get();
    for (final lecDoc in lecciones.docs) {
      await eliminarLeccion(cursoId, moduloId, lecDoc.id);
    }
    await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .delete();
  }

  // ── LECCIONES ───────────────────────────────────────────────────────────────

  static Stream<List<LeccionModel>> streamLecciones(
      String cursoId, String moduloId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .orderBy('orden')
        .snapshots()
        .map((snap) => snap.docs.map(LeccionModel.fromDoc).toList());
  }

  static Future<void> crearLeccion(
      String cursoId, String moduloId, LeccionModel leccion) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .add(leccion.toMap());
  }

  static Future<void> eliminarLeccion(
      String cursoId, String moduloId, String leccionId) async {
    final ejercicios = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .collection('ejercicios')
        .get();
    for (final ejDoc in ejercicios.docs) {
      await ejDoc.reference.delete();
    }
    await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .delete();
  }

  // ── EJERCICIOS ──────────────────────────────────────────────────────────────

  static Stream<List<EjercicioModel>> streamEjercicios(
      String cursoId, String moduloId, String leccionId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .collection('ejercicios')
        .snapshots()
        .map((snap) => snap.docs.map(EjercicioModel.fromDoc).toList());
  }

  static Future<void> crearEjercicio(String cursoId, String moduloId,
      String leccionId, EjercicioModel ejercicio) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .collection('ejercicios')
        .add(ejercicio.toMap());
  }

  static Future<void> eliminarEjercicio(String cursoId, String moduloId,
      String leccionId, String ejercicioId) {
    return _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .doc(moduloId)
        .collection('lecciones')
        .doc(leccionId)
        .collection('ejercicios')
        .doc(ejercicioId)
        .delete();
  }

  // ── CONTAR MÓDULOS (para mostrar en tarjeta) ─────────────────────────────────
  static Future<int> contarModulos(String cursoId) async {
    final snap = await _db
        .collection('cursos')
        .doc(cursoId)
        .collection('modulos')
        .count()
        .get();
    return snap.count ?? 0;
  }
}

// ─── 1. PANTALLA PRINCIPAL: GESTIÓN DE CURSOS ───────────────────────────────

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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CursosService.eliminarCurso(curso.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Curso eliminado')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text('Gestión de Cursos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cursos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'A1', 'A2', 'B1', 'B2', 'C1']
                    .map((nivel) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(nivel),
                            selected: selectedNivel == nivel,
                            selectedColor: AppColors.secundario,
                            labelStyle: TextStyle(
                              color: selectedNivel == nivel
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) =>
                                setState(() => selectedNivel = nivel),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final curso = cursos[index];
                    return _CursoAdminCard(
                      curso: curso,
                      onEditar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditCursoScreen(curso: curso))),
                      onEliminar: () => _confirmarEliminar(context, curso),
                      onVerModulos: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ModulosAdminScreen(cursoId: curso.id, cursoTitulo: curso.titulo))),
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

// ─── TARJETA DE CURSO ─────────────────────────────────────────────────────────

class _CursoAdminCard extends StatelessWidget {
  final CursoModel curso;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onVerModulos;

  const _CursoAdminCard({
    required this.curso,
    required this.onEditar,
    required this.onEliminar,
    required this.onVerModulos,
  });

  Color get _nivelColor {
    switch (curso.nivel) {
      case 'A1':
      case 'A2':
        return Colors.green;
      case 'B1':
      case 'B2':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onVerModulos,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Imagen de portada o icono
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: curso.imagenUrl.isNotEmpty
                      ? Image.network(
                          curso.imagenUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _iconoFallback(),
                        )
                      : _iconoFallback(),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(curso.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Nivel ${curso.nivel}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEditar,
                      child: const Icon(Icons.edit_outlined,
                          size: 20, color: Colors.blue),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: onEliminar,
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.view_module_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    FutureBuilder<int>(
                      future: CursosService.contarModulos(curso.id),
                      builder: (context, snap) => Text(
                        '${snap.data ?? '...'} módulos',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: curso.publicado
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    curso.publicado ? 'PUBLICADO' : 'BORRADOR',
                    style: TextStyle(
                      color: curso.publicado ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconoFallback() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _nivelColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.import_contacts, color: _nivelColor),
      );
}

// ─── 2. PANTALLA: AÑADIR NUEVO CURSO ──────────────────────────────────────────

class AddCursoScreen extends StatefulWidget {
  const AddCursoScreen({super.key});

  @override
  State<AddCursoScreen> createState() => _AddCursoScreenState();
}

class _AddCursoScreenState extends State<AddCursoScreen> {
  bool _isPublicado = true;
  bool _isSaving = false;
  File? _imagenLocal;
  String _nivelSeleccionado = 'A1';

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  // Lista temporal de módulos antes de crear el curso
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
    if (picked != null) setState(() => _imagenLocal = File(picked.path));
  }

  Future<void> _guardarCurso() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      _mostrarSnackbar('El título es obligatorio');
      return;
    }
    setState(() => _isSaving = true);
    try {
      // 1. Crear documento del curso (sin imagen aún)
      final cursoId = await CursosService.crearCurso(CursoModel(
        id: '',
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        nivel: _nivelSeleccionado,
        imagenUrl: '',
        publicado: _isPublicado,
      ));

      // 2. Subir imagen si hay una seleccionada
      if (_imagenLocal != null) {
        final url = await CursosService.subirImagen(_imagenLocal!, cursoId);
        await CursosService.actualizarCurso(cursoId, {'imagen_url': url});
      }

      // 3. Crear módulos en orden
      for (int i = 0; i < _modulosTitulos.length; i++) {
        await CursosService.crearModulo(
          cursoId,
          ModuloModel(
              id: '', titulo: _modulosTitulos[i], descripcion: '', orden: i),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showAddModuloPopup() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Módulo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Label(text: 'Nombre del módulo'),
            _AppTextField(controller: ctrl, hint: 'Ej. Los Colores'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() => _modulosTitulos.add(ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.secundario),
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
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            const _Label(text: 'Título del Curso'),
            _AppTextField(
                controller: _tituloCtrl, hint: 'Ej. Náhuatl Básico A1'),
            const SizedBox(height: 20),
            _buildVisibilityToggle(),
            const SizedBox(height: 20),
            const _Label(text: 'Descripción'),
            _AppTextField(
                controller: _descripcionCtrl,
                hint: 'Describe brevemente el curso...',
                maxLines: 3),
            const SizedBox(height: 20),
            const _Label(text: 'Nivel'),
            _NivelDropdown(
              value: _nivelSeleccionado,
              onChanged: (v) => setState(() => _nivelSeleccionado = v!),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Módulos del Curso',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ModuleCardAdmin(
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
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isPublicado ? 'PUBLICAR CURSO' : 'GUARDAR PRIVADO',
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
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secundario.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secundario.withOpacity(0.1)),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                    _isPublicado
                        ? 'Público para estudiantes'
                        : 'Privado (Borrador)',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: _isPublicado,
            activeColor: AppColors.secundario,
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
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        child: _imagenLocal != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_imagenLocal!, fit: BoxFit.cover))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('Subir imagen de portada',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
      ),
    );
  }
}

// ─── 3. PANTALLA: EDITAR CURSO ────────────────────────────────────────────────

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
    _nivelSeleccionado = widget.curso.nivel;
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
        imagenUrl =
            await CursosService.subirImagen(_imagenLocal!, widget.curso.id);
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                                  size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text('Cambiar imagen de portada',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 14)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            const _Label(text: 'Título del Curso'),
            _AppTextField(controller: _tituloCtrl, hint: 'Ej. Náhuatl Básico A1'),
            const SizedBox(height: 20),
            const _Label(text: 'Descripción'),
            _AppTextField(
                controller: _descripcionCtrl,
                hint: 'Describe brevemente el curso...',
                maxLines: 3),
            const SizedBox(height: 20),
            const _Label(text: 'Nivel'),
            _NivelDropdown(
              value: _nivelSeleccionado,
              onChanged: (v) => setState(() => _nivelSeleccionado = v!),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secundario.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.secundario.withOpacity(0.1)),
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
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublicado,
                    activeColor: AppColors.secundario,
                    onChanged: (val) => setState(() => _isPublicado = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Botón para ir a gestionar módulos del curso existente
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

// ─── 4. PANTALLA: MÓDULOS DEL CURSO ──────────────────────────────────────────

class ModulosAdminScreen extends StatelessWidget {
  final String cursoId;
  final String cursoTitulo;

  const ModulosAdminScreen(
      {super.key, required this.cursoId, required this.cursoTitulo});

  Future<void> _confirmarEliminar(
      BuildContext context, String moduloId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar módulo?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Se eliminarán el módulo y todas sus lecciones y ejercicios.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CursosService.eliminarModulo(cursoId, moduloId);
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
            const _Label(text: 'Título'),
            _AppTextField(controller: tituloCtrl, hint: 'Ej. Los Colores'),
            const SizedBox(height: 12),
            const _Label(text: 'Descripción'),
            _AppTextField(
                controller: descCtrl,
                hint: 'Breve descripción...',
                maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (tituloCtrl.text.isNotEmpty) {
                await CursosService.crearModulo(
                  cursoId,
                  ModuloModel(
                      id: '',
                      titulo: tituloCtrl.text.trim(),
                      descripcion: descCtrl.text.trim(),
                      orden: nextOrden),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario),
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
        title: Text(cursoTitulo,
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
        stream: CursosService.streamModulos(cursoId),
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
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () =>
                          _showAddModuloPopup(context, modulos.length),
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
                if (modulos.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay módulos aún. ¡Añade el primero!',
                        style: TextStyle(color: Colors.grey)),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: modulos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final modulo = modulos[index];
                      return _ModuleCardAdmin(
                        index: index + 1,
                        title: modulo.titulo,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CrearEjerciciosScreen(
                              cursoId: cursoId,
                              moduloId: modulo.id,
                              moduloTitulo: modulo.titulo,
                            ),
                          ),
                        ),
                        onDelete: () =>
                            _confirmarEliminar(context, modulo.id),
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

// ─── 5. PANTALLA: EDITAR MÓDULO / CREAR EJERCICIOS ───────────────────────────

class CrearEjerciciosScreen extends StatefulWidget {
  final String cursoId;
  final String moduloId;
  final String moduloTitulo;

  const CrearEjerciciosScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.moduloTitulo,
  });

  @override
  State<CrearEjerciciosScreen> createState() => _CrearEjerciciosScreenState();
}

class _CrearEjerciciosScreenState extends State<CrearEjerciciosScreen> {
  late final TextEditingController _moduloNameController;
  bool _isSavingName = false;

  // Para simplificar: mostramos lecciones; cada lección agrupa ejercicios.
  // Aquí usamos la primera lección del módulo como contenedor de ejercicios.
  // Si tu estructura quiere usar lecciones separadas, puedes expandir este patrón.

  @override
  void initState() {
    super.initState();
    _moduloNameController =
        TextEditingController(text: widget.moduloTitulo);
  }

  @override
  void dispose() {
    _moduloNameController.dispose();
    super.dispose();
  }

  Future<void> _guardarNombreModulo() async {
    setState(() => _isSavingName = true);
    await CursosService.actualizarModulo(
        widget.cursoId, widget.moduloId, {'titulo': _moduloNameController.text.trim()});
    setState(() => _isSavingName = false);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Módulo actualizado ✅')));
    }
  }

  void _showNewEjercicioPopup(BuildContext context, String leccionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewEjercicioActionCards(
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
        title: const Text('¿Eliminar ejercicio?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Módulo',
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
        stream: CursosService.streamLecciones(widget.cursoId, widget.moduloId),
        builder: (context, lecSnap) {
          final lecciones = lecSnap.data ?? [];

          // Auto-crear la primera lección si no existe
          if (lecSnap.connectionState == ConnectionState.active &&
              lecciones.isEmpty) {
            CursosService.crearLeccion(
              widget.cursoId,
              widget.moduloId,
              LeccionModel(
                  id: '',
                  titulo: 'Lección Principal',
                  descripcion: '',
                  orden: 0),
            );
          }

          final leccionId =
              lecciones.isNotEmpty ? lecciones.first.id : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label(text: 'Nombre del Módulo'),
                Row(
                  children: [
                    Expanded(
                      child: _AppTextField(
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
                          : const Icon(Icons.save_outlined,
                              color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 32),
                if (leccionId != null) ...[
                  StreamBuilder<List<EjercicioModel>>(
                    stream: CursosService.streamEjercicios(
                        widget.cursoId, widget.moduloId, leccionId),
                    builder: (context, ejSnap) {
                      final ejercicios = ejSnap.data ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ejercicios (${ejercicios.length})',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () => _showNewEjercicioPopup(
                                    context, leccionId),
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
                          if (ejercicios.isEmpty)
                            const Center(
                                child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No hay ejercicios aún.',
                                  style: TextStyle(color: Colors.grey)),
                            ))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: ejercicios.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final ej = ejercicios[index];
                                return _EjercicioCardAdmin(
                                  contenido: ej.contenido,
                                  tipo: ej.tipoEjercicio,
                                  dificultad: ej.dificultad,
                                  respuesta: ej.respuesta,
                                  pista: ej.pista,
                                  onEdit: () {},
                                  onDelete: () =>
                                      _confirmarEliminarEjercicio(
                                          leccionId, ej.id),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ] else
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── 6. PANTALLA: GENERAR CON IA ──────────────────────────────────────────────

class GenerarConIAScreen extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const GenerarConIAScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> suggestedExercises = [
      {
        'title': 'Traducción: Jaguar',
        'level': 'BÁSICO',
        'description': '"El jaguar es el rey de la selva...."',
        'response': 'Ocelotl',
        'culturalContext':
            'En la mitología náhuatl, el jaguar (ocelotl) representaba a Tezcatlipoca.',
        'color': Colors.green,
      },
      {
        'title': 'Parejas: Sonidos',
        'level': 'INTERMEDIO',
        'description': 'Relacionar animal con su onomatopeya...',
        'response': 'Tochtli - Cuicatl',
        'culturalContext':
            'El concepto de la voz animal es fundamental en la poesía náhuatl.',
        'color': Colors.purple,
      },
      {
        'title': 'Completar: Serpiente',
        'level': 'BÁSICO',
        'description': '"La __ emplumada es un dios..."',
        'response': 'Coatl',
        'culturalContext':
            'Quetzalcoatl proviene de Quetzal (ave) y Coatl (serpiente).',
        'color': Colors.cyan,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('GENERAR CON IA',
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
            _InputCard(
              title: 'TEMA O PALABRA CLAVE',
              hintText: 'ej. Animales de la selva',
              onGenerate: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generando ejercicios...')));
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EJERCICIOS SUGERIDOS',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _Badge(
                    text: '${suggestedExercises.length} RESULTADOS',
                    color: const Color(0xFFE2F4F2),
                    textColor: const Color(0xFF43706F)),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestedExercises.map((exercise) => _SuggestionCard(
                  cursoId: cursoId,
                  moduloId: moduloId,
                  leccionId: leccionId,
                  title: exercise['title'],
                  level: exercise['level'],
                  description: exercise['description'],
                  response: exercise['response'],
                  culturalContext: exercise['culturalContext'],
                  accentColor: exercise['color'],
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── 7. PANTALLAS: CREAR EJERCICIOS MANUALMENTE ───────────────────────────────

// 7a. Leer y Escribir
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

class _CrearLeerYEscribirScreenState
    extends State<CrearLeerYEscribirScreen> {
  double _aiTolerance = 2.0;
  bool _consentChecked = true;
  bool _isSaving = false;

  final _instruccionCtrl = TextEditingController();
  final _textoObjetivoCtrl = TextEditingController();

  @override
  void dispose() {
    _instruccionCtrl.dispose();
    _textoObjetivoCtrl.dispose();
    super.dispose();
  }

  String get _toleranciaLabel =>
      _aiTolerance == 1.0 ? 'Permisivo' : _aiTolerance == 2.0 ? 'Equilibrado' : 'Estricto';

  Future<void> _guardar() async {
    if (_textoObjetivoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El texto objetivo es obligatorio')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await CursosService.crearEjercicio(
        widget.cursoId,
        widget.moduloId,
        widget.leccionId,
        EjercicioModel(
          id: '',
          tipoEjercicio: 'leer_y_escribir',
          contenido: _instruccionCtrl.text.trim().isNotEmpty
              ? _instruccionCtrl.text.trim()
              : _textoObjetivoCtrl.text.trim(),
          dificultad: _toleranciaLabel,
          respuesta: _textoObjetivoCtrl.text.trim(),
          pista: '',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ejercicio guardado ✅')));
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
        title: Text('EJERCICIO LEER Y ESCRIBIR',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
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
            const _Label(text: 'INSTRUCCIÓN'),
            _AppTextField(
                controller: _instruccionCtrl,
                hint: 'Leer y repite la frase'),
            const SizedBox(height: 20),
            const _Label(text: 'TEXTO OBJETIVO (NÁHUATL)'),
            _AppTextField(
                controller: _textoObjetivoCtrl, hint: '¿Quen tinemi?'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Label(text: 'TOLERANCIA DE ESCRITURA (IA)'),
                _Badge(
                    text: _toleranciaLabel,
                    color: const Color(0xFFC7E8E0),
                    textColor: AppColors.secundario),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.secundario,
                inactiveTrackColor: Colors.grey[100],
                thumbColor: AppColors.secundario,
                trackHeight: 12,
                tickMarkShape: SliderTickMarkShape.noTickMark,
              ),
              child: Slider(
                value: _aiTolerance,
                min: 1.0,
                max: 3.0,
                divisions: 2,
                onChanged: (val) => setState(() => _aiTolerance = val),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('PERMISIVO',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text('EQUILIBRADO',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text('ESTRICTO',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 32),
            _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (val) => setState(() => _consentChecked = val!)),
            const SizedBox(height: 32),
            _SaveButton(onSave: _guardar, isSaving: _isSaving),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 7b. Imagen y Palabra
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

class _CrearImagenYPalabraScreenState
    extends State<CrearImagenYPalabraScreen> {
  int _correctIndex = 0;
  bool _consentChecked = false;
  bool _isSaving = false;

  final _palabraCtrl = TextEditingController();

  @override
  void dispose() {
    _palabraCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_palabraCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La palabra/concepto es obligatoria')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await CursosService.crearEjercicio(
        widget.cursoId,
        widget.moduloId,
        widget.leccionId,
        EjercicioModel(
          id: '',
          tipoEjercicio: 'imagen_y_palabra',
          contenido: _palabraCtrl.text.trim(),
          dificultad: 'basico',
          respuesta: _correctIndex.toString(),
          pista: '',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ejercicio guardado ✅')));
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
        title: Text('EJERCICIO IMÁGENES Y PALABRAS',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
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
            const _Label(text: 'PALABRA / CONCEPTO'),
            _AppTextField(controller: _palabraCtrl, hint: 'Tepetl'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Label(text: 'OPCIONES (4 IMÁGENES)'),
                Text('MARCAR LA CORRECTA',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: List.generate(
                  4,
                  (index) => _ImageOptionCard(
                        index: index,
                        isCorrect: _correctIndex == index,
                        onCorrected: () =>
                            setState(() => _correctIndex = index),
                      )),
            ),
            const SizedBox(height: 32),
            _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (val) => setState(() => _consentChecked = val!)),
            const SizedBox(height: 32),
            _SaveButton(onSave: _guardar, isSaving: _isSaving),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 7c. Completar Frase
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

class _CrearCompletarFraseScreenState
    extends State<CrearCompletarFraseScreen> {
  int _correctOptionIndex = 0;
  bool _consentChecked = true;
  bool _isSaving = false;

  final _fraseCtrl = TextEditingController();
  final _explicacionCtrl = TextEditingController();
  final List<TextEditingController> _opcionCtrl =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    _fraseCtrl.dispose();
    _explicacionCtrl.dispose();
    for (final c in _opcionCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_fraseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La frase es obligatoria')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await CursosService.crearEjercicio(
        widget.cursoId,
        widget.moduloId,
        widget.leccionId,
        EjercicioModel(
          id: '',
          tipoEjercicio: 'completar_frase',
          contenido: _fraseCtrl.text.trim(),
          dificultad: 'intermedio',
          respuesta: _correctOptionIndex.toString(),
          pista: _explicacionCtrl.text.trim(),
          opciones: _opcionCtrl.map((c) => c.text.trim()).toList(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ejercicio guardado ✅')));
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
        title: Text('EJERCICIO COMPLETAR FRASE',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
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
            const _Label(text: 'FRASE CON HUECO'),
            _AppTextField(
              controller: _fraseCtrl,
              hint: "Ej. Nehuatl ____ nahuatlahtolli.",
              maxLines: 4,
            ),
            const SizedBox(height: 6),
            const Text("Usa '____' para marcar el hueco.",
                style: TextStyle(
                    color: AppColors.secundario,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Label(text: 'OPCIONES'),
                Text('Selecciona la Correcta',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(
                4,
                (index) => _OptionFraseCard(
                      index: index,
                      controller: _opcionCtrl[index],
                      isCorrect: _correctOptionIndex == index,
                      onSelected: () =>
                          setState(() => _correctOptionIndex = index),
                    )),
            const SizedBox(height: 24),
            const _Label(text: 'EXPLICACIÓN DEL ERROR (IA FEEDBACK)'),
            _AppTextField(
                controller: _explicacionCtrl,
                hint:
                    'Explica por qué las otras opciones son incorrectas...',
                maxLines: 4),
            const SizedBox(height: 32),
            _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (val) => setState(() => _consentChecked = val!)),
            const SizedBox(height: 32),
            _SaveButton(onSave: _guardar, isSaving: _isSaving),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 7d. Escuchar y Hablar
class CrearEscucharYHablarScreen extends StatefulWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const CrearEscucharYHablarScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  State<CrearEscucharYHablarScreen> createState() =>
      _CrearEscucharYHablarScreenState();
}

class _CrearEscucharYHablarScreenState
    extends State<CrearEscucharYHablarScreen> {
  bool _isSaving = false;
  final _instruccionCtrl = TextEditingController();
  final _textoObjetivoCtrl = TextEditingController();

  @override
  void dispose() {
    _instruccionCtrl.dispose();
    _textoObjetivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _isSaving = true);
    try {
      await CursosService.crearEjercicio(
        widget.cursoId,
        widget.moduloId,
        widget.leccionId,
        EjercicioModel(
          id: '',
          tipoEjercicio: 'escuchar_y_hablar',
          contenido: _instruccionCtrl.text.trim().isNotEmpty
              ? _instruccionCtrl.text.trim()
              : _textoObjetivoCtrl.text.trim(),
          dificultad: 'intermedio',
          respuesta: _textoObjetivoCtrl.text.trim(),
          pista: '',
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ejercicio guardado ✅')));
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
        title: Text('EJERCICIO ESCUCHAR Y HABLAR',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.spatial_audio_outlined,
                size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('Editor de Escuchar y Hablar',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
                'Configura el texto objetivo y la instrucción para el ejercicio de voz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const _Label(text: 'INSTRUCCIÓN'),
            _AppTextField(
                controller: _instruccionCtrl,
                hint: 'Ej. Escucha y repite la frase'),
            const SizedBox(height: 16),
            const _Label(text: 'TEXTO OBJETIVO'),
            _AppTextField(
                controller: _textoObjetivoCtrl, hint: 'Ej. Nimitztlazohtla'),
            const Spacer(),
            _SaveButton(onSave: _guardar, isSaving: _isSaving),
          ],
        ),
      ),
    );
  }
}

// ─── COMPONENTES UI ───────────────────────────────────────────────────────────

class _NewEjercicioActionCards extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const _NewEjercicioActionCards({
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  Widget build(BuildContext context) {
    final activityTypes = [
      {'title': 'Leer y Escribir', 'icon': Icons.edit_note_outlined},
      {'title': 'Imagen y Palabra', 'icon': Icons.image_outlined},
      {'title': 'Escuchar y Hablar', 'icon': Icons.spatial_audio_outlined},
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
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Nuevo Ejercicio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Selecciona el tipo de actividad para tu módulo',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          ...activityTypes.map((type) => _ActivityActionCard(
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

class _ActivityActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const _ActivityActionCard({
    required this.title,
    required this.icon,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7E8E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secundario),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
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
                          cursoId: cursoId,
                          moduloId: moduloId,
                          leccionId: leccionId);
                    } else if (title == 'Imagen y Palabra') {
                      destScreen = CrearImagenYPalabraScreen(
                          cursoId: cursoId,
                          moduloId: moduloId,
                          leccionId: leccionId);
                    } else if (title == 'Escuchar y Hablar') {
                      destScreen = CrearEscucharYHablarScreen(
                          cursoId: cursoId,
                          moduloId: moduloId,
                          leccionId: leccionId);
                    } else {
                      destScreen = CrearCompletarFraseScreen(
                          cursoId: cursoId,
                          moduloId: moduloId,
                          leccionId: leccionId);
                    }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => destScreen));
                  },
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.grey),
                  label:
                      const Text('Manualmente', style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                    backgroundColor: AppColors.secundario.withOpacity(0.15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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

// ─── WIDGETS AUXILIARES ───────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final Widget? suffixWidget;
  final int maxLines;
  final TextEditingController? controller;

  const _AppTextField({
    required this.hint,
    this.icon,
    this.suffixWidget,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            suffixIcon: suffixWidget != null
                ? null
                : (icon != null ? Icon(icon, color: Colors.grey[400]) : null),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        ),
        if (suffixWidget != null)
          Positioned(
            bottom: 4,
            right: 4,
            child: suffixWidget!,
          ),
      ],
    );
  }
}

class _NivelDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _NivelDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: ['A1', 'A2', 'B1', 'B2', 'C1']
            .map((n) => DropdownMenuItem(value: n, child: Text(n)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _ModuleCardAdmin extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ModuleCardAdmin({
    required this.index,
    required this.title,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secundario.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('$index',
                style: const TextStyle(
                    color: AppColors.secundario,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Toca para ver ejercicios',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 20, color: Colors.grey),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EjercicioCardAdmin extends StatelessWidget {
  final String contenido;
  final String tipo;
  final String dificultad;
  final String respuesta;
  final String pista;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EjercicioCardAdmin({
    required this.contenido,
    required this.tipo,
    required this.dificultad,
    required this.respuesta,
    required this.pista,
    required this.onEdit,
    required this.onDelete,
  });

  IconData get _tipoIcon {
    switch (tipo) {
      case 'leer_escribir':
      case 'leer_y_escribir':
        return Icons.edit_note_outlined;
      case 'imagen_y_palabra':
        return Icons.image_outlined;
      case 'escuchar_y_hablar':
        return Icons.spatial_audio_outlined;
      case 'completar_frase':
        return Icons.text_fields_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  Color _dificultadColor(BuildContext context) {
    switch (dificultad.toLowerCase()) {
      case 'basico':
      case 'básico':
      case 'permisivo':
        return Colors.green;
      case 'intermedio':
      case 'equilibrado':
        return Colors.orange;
      case 'avanzado':
      case 'estricto':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final diffColor = _dificultadColor(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icono + tipo + badge dificultad + acciones
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secundario.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_tipoIcon,
                      color: AppColors.secundario, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipo.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.secundario,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dificultad.toUpperCase(),
                          style: TextStyle(
                              color: diffColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: colorScheme.onSurface.withOpacity(0.4)),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.redAccent),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Contenido
            Text(
              contenido,
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (respuesta.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.secundario),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Respuesta: $respuesta',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secundario,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (pista.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 13,
                      color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Pista: $pista',
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;
  final String title;
  final String level;
  final String description;
  final String response;
  final String culturalContext;
  final Color accentColor;

  const _SuggestionCard({
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
    required this.title,
    required this.level,
    required this.description,
    required this.response,
    required this.culturalContext,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              _Badge(
                  text: level,
                  color: accentColor.withOpacity(0.1),
                  textColor: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Respuesta:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(response,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                                text: 'Contexto Cultural: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 11)),
                            TextSpan(
                                text: culturalContext,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.grey),
                  label: const Text('Editar',
                      style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await CursosService.crearEjercicio(
                      cursoId,
                      moduloId,
                      leccionId,
                      EjercicioModel(
                        id: '',
                        tipoEjercicio: 'ia_generado',
                        contenido: description,
                        dificultad: level,
                        respuesta: response,
                        pista: culturalContext,
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ejercicio añadido ✅')));
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline,
                      size: 16, color: Colors.white),
                  label: const Text('Añadir',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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

class _InputCard extends StatelessWidget {
  final String title;
  final String hintText;
  final VoidCallback onGenerate;

  const _InputCard(
      {required this.title,
      required this.hintText,
      required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: title),
          _AppTextField(hint: hintText, icon: Icons.edit_outlined),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 20),
              label: const Text('Generar con IA',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _MediaButton({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secundario, size: 30),
          const SizedBox(height: 12),
          Text(text,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ImageOptionCard extends StatelessWidget {
  final int index;
  final bool isCorrect;
  final VoidCallback onCorrected;

  const _ImageOptionCard(
      {required this.index,
      required this.isCorrect,
      required this.onCorrected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _MediaButton(text: 'SUBIR IMAGEN', icon: Icons.image_outlined),
              const SizedBox(height: 12),
              _AppTextField(hint: 'Texto Alt (Ej. Montaña)'),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onCorrected,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                ),
                child: isCorrect
                    ? const Icon(Icons.check_circle,
                        color: AppColors.secundario, size: 24)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionFraseCard extends StatelessWidget {
  final int index;
  final bool isCorrect;
  final VoidCallback onSelected;
  final TextEditingController controller;

  const _OptionFraseCard({
    required this.index,
    required this.isCorrect,
    required this.onSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCorrect
                ? AppColors.secundario.withOpacity(0.5)
                : Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Radio(
            value: index,
            groupValue: isCorrect ? index : -1,
            onChanged: (_) => onSelected(),
            activeColor: AppColors.secundario,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Opción ${index + 1}',
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;

  const _ConsentCheckbox(
      {required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secundario.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secundario.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: onChanged,
            activeColor: AppColors.secundario,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                'Acepto que estos datos sean utilizados para mejorar el modelo de IA de la plataforma.',
                style: TextStyle(color: AppColors.primario, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool isSaving;

  const _SaveButton({required this.onSave, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onSave,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_outlined, color: Colors.white),
        label: Text(isSaving ? 'Guardando...' : 'Guardar Ejercicio',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secundario,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Badge(
      {required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}