import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ─── 1. PANTALLA PRINCIPAL: GESTIÓN DE CURSOS ───────────────────────────────
class CursosAdminScreen extends StatefulWidget {
  const CursosAdminScreen({super.key});

  @override
  State<CursosAdminScreen> createState() => _CursosAdminScreenState();
}

class _CursosAdminScreenState extends State<CursosAdminScreen> {
  String selectedNivel = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allCursos = [
    {
      'titulo': 'Náhuatl para Principiantes',
      'nivel': 'A1',
      'modulos': 12,
      'estudiantes': 450,
      'estado': 'Publicado',
      'color': Colors.green,
    },
    {
      'titulo': 'Gramática Avanzada',
      'nivel': 'B2',
      'modulos': 8,
      'estudiantes': 120,
      'estado': 'Borrador',
      'color': Colors.purple,
    },
  ];

  List<Map<String, dynamic>> _filteredCursos = [];

  @override
  void initState() {
    super.initState();
    _filteredCursos = _allCursos;
    _searchController.addListener(_runFilter);
  }

  void _runFilter() {
    List<Map<String, dynamic>> results = [];
    String query = _searchController.text.toLowerCase();

    results = _allCursos.where((curso) {
      final matchesSearch = curso['titulo'].toLowerCase().contains(query);
      final matchesNivel =
          selectedNivel == 'Todos' || curso['nivel'] == selectedNivel;
      return matchesSearch && matchesNivel;
    }).toList();

    setState(() {
      _filteredCursos = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCursoScreen()),
          );
        },
        backgroundColor: AppColors.secundario,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Cursos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cursos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
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
                            onSelected: (val) {
                              setState(() => selectedNivel = nivel);
                              _runFilter();
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 25),
            _filteredCursos.isEmpty
                ? const Center(child: Text("No se encontraron cursos"))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCursos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _CursoAdminCard(
                        curso: _filteredCursos[index],
                        onAction: (accion) {},
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

class _CursoAdminCard extends StatelessWidget {
  final Map<String, dynamic> curso;
  final Function(String) onAction;

  const _CursoAdminCard({required this.curso, required this.onAction});

  @override
  Widget build(BuildContext context) {
    bool isPublicado = curso['estado'] == 'Publicado';

    return Container(
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: curso['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.import_contacts, color: curso['color']),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(curso['titulo'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Nivel ${curso['nivel']} • ${curso['modulos']} Módulos',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Icon(Icons.copy_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
                  const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${curso['estudiantes']} estudiantes',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPublicado
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  curso['estado'].toUpperCase(),
                  style: TextStyle(
                    color: isPublicado ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ─── PANTALLA: AÑADIR NUEVO CURSO ──────────────────────────────────────────
class AddCursoScreen extends StatefulWidget {
  const AddCursoScreen({super.key});

  @override
  State<AddCursoScreen> createState() => _AddCursoScreenState();
}

class _AddCursoScreenState extends State<AddCursoScreen> {
  bool isPublicado = true;
  final List<String> modulosList = [
    'Introducción al Náhuatl',
    'Los Saludos y Presentaciones',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Añadir Nuevo Curso',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _notificar(context, "Borrador guardado localmente"),
            child: const Text('Guardar Borrador',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
            const _TextField(hint: 'Ej. Náhuatl Básico A1'),
            const SizedBox(height: 20),
            _buildVisibilityToggle(),
            const SizedBox(height: 20),
            const _Label(text: 'Descripción'),
            const _TextField(hint: 'Describe brevemente el curso...', maxLines: 3),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                    child: _InputGroup(
                        label: 'Nivel',
                        hint: 'A1',
                        icon: Icons.keyboard_arrow_down)),
                SizedBox(width: 16),
                Expanded(
                    child: _InputGroup(
                        label: 'Idioma',
                        hint: 'Náhuatl',
                        icon: Icons.keyboard_arrow_down)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Módulos del Curso',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _showAddModuloPopup(context),
                  icon: const Icon(Icons.add, size: 18, color: AppColors.secundario),
                  label: const Text('AÑADIR',
                      style: TextStyle(
                          color: AppColors.secundario, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modulosList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ModuleCardAdmin(
                  index: index + 1,
                  title: modulosList[index],
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CrearEjerciciosScreen())),
                );
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primario,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(isPublicado ? 'PUBLICAR CURSO' : 'GUARDAR PRIVADO',
                    style: const TextStyle(
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

  void _showAddModuloPopup(BuildContext context) {
    final TextEditingController moduloController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Módulo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Label(text: 'Nombre del módulo'),
            _TextField(controller: moduloController, hint: 'Ej. Los Colores'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (moduloController.text.isNotEmpty) {
                setState(() => modulosList.add(moduloController.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secundario),
            child: const Text('Añadir', style: TextStyle(color: Colors.white)),
          ),
        ],
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
              isPublicado
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.secundario),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Visibilidad",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                    isPublicado
                        ? "Público para estudiantes"
                        : "Privado (Borrador)",
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: isPublicado,
            activeColor: AppColors.secundario,
            onChanged: (val) => setState(() => isPublicado = val),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('Subir imagen de portada',
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  void _notificar(BuildContext context, String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
}

// ─── PANTALLA: EDITAR MÓDULO / CREAR EJERCICIOS ──────────────────────────────
class CrearEjerciciosScreen extends StatefulWidget {
  const CrearEjerciciosScreen({super.key});

  @override
  State<CrearEjerciciosScreen> createState() => _CrearEjerciciosScreenState();
}

class _CrearEjerciciosScreenState extends State<CrearEjerciciosScreen> {
  final TextEditingController _moduloNameController =
      TextEditingController(text: 'Introducción al Náhuatl');

  final List<Map<String, String>> ejerciciosList = [
    {'title': 'Vocabulario Básico de Saludos', 'type': 'Selección Múltiple'},
    {'title': 'Lectura Comprensiva: La Familia', 'type': 'Lectura'},
    {'title': 'Ordenar Oraciones Simples', 'type': 'Ordenar'},
    {'title': 'Completar Espacios en Blanco', 'type': 'Completar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Módulo',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label(text: 'Nombre del Módulo'),
            _TextField(
                controller: _moduloNameController,
                hint: 'Ej. Los Colores',
                icon: Icons.edit_outlined),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ejercicios (${ejerciciosList.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showNewEjercicioPopup(context),
                  icon: const Icon(Icons.add, size: 18, color: AppColors.secundario),
                  label: const Text('AÑADIR',
                      style: TextStyle(
                          color: AppColors.secundario, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ejerciciosList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _EjercicioCardAdmin(
                  title: ejerciciosList[index]['title']!,
                  type: ejerciciosList[index]['type']!,
                  onEdit: () {},
                );
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primario,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'GUARDAR CAMBIOS',
                  style: TextStyle(
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

  void _showNewEjercicioPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NewEjercicioActionCards(),
    );
  }
}

// --- COMPONENTES UI AUXILIARES ---

class _NewEjercicioActionCards extends StatelessWidget {
  const _NewEjercicioActionCards();

  @override
  Widget build(BuildContext context) {
    final activityTypes = [
      {
        'title': 'Leer y Escribir',
        'icon': Icons.edit_note_outlined,
      },
      {
        'title': 'Imagen y Palabra',
        'icon': Icons.image_outlined,
      },
      {
        'title': 'Escuchar y Hablar',
        'icon': Icons.spatial_audio_outlined,
      },
      {
        'title': 'Completar Frase',
        'icon': Icons.text_fields_outlined,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
          const Text(
            'Nuevo Ejercicio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona el tipo de actividad para tu módulo',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ...activityTypes.map((type) => _ActivityActionCard(
                title: type['title'] as String,
                icon: type['icon'] as IconData,
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

  const _ActivityActionCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final aiColor = AppColors.secundario.withOpacity(0.15);
    final aiIconColor = AppColors.secundario;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el popup
                    Widget destScreen;
                    // Mapeo condicional basado en image_4.png
                    if (title == 'Leer y Escribir') {
                      destScreen = const CrearLeerYEscribirScreen();
                    } else if (title == 'Imagen y Palabra') {
                      destScreen = const CrearImagenYPalabraScreen();
                    } else if (title == 'Escuchar y Hablar') {
                      destScreen = const CrearEscucharYHablarScreen();
                    } else if (title == 'Completar Frase') {
                      destScreen = const CrearCompletarFraseScreen();
                    } else {
                      return; // No debería pasar
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => destScreen),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.grey),
                  label: const Text('Manualmente',
                      style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
                            builder: (context) => const GenerarConIAScreen()));
                  },
                  icon: Icon(Icons.auto_awesome_outlined,
                      size: 16, color: aiIconColor),
                  label: Text('Generar con IA',
                      style: TextStyle(color: aiIconColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aiColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// ─── 5a. PANTALLA: GENERAR CON IA (image_3.png) ──────────────────────────────
class GenerarConIAScreen extends StatelessWidget {
  const GenerarConIAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> suggestedExercises = [
      {
        'title': 'Traducción: Jaguar',
        'level': 'BÁSICO',
        'description': '"El jaguar es el rey de la selva...."',
        'response': 'Ocelotl',
        'culturalContext':
            'En la mitología náhuatl, el jaguar (ocelotl) representaba a Tezcatlipoca y el valor guerrero.',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GENERAR CON IA',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
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
                const Text(
                  'EJERCICIOS SUGERIDOS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _Badge(
                    text: '${suggestedExercises.length} RESULTADOS',
                    color: const Color(0xFFE2F4F2),
                    textColor: const Color(0xFF43706F)),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestedExercises.map((exercise) => _SuggestionCard(
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

// ─── 5b. NUEVAS PANTALLAS: CREAR MANUALMENTE (image_4.png) ───────────────────

// Pantalla: Crear Leer y Escribir (image_4.png izq.)
class CrearLeerYEscribirScreen extends StatefulWidget {
  const CrearLeerYEscribirScreen({super.key});

  @override
  State<CrearLeerYEscribirScreen> createState() =>
      _CrearLeerYEscribirScreenState();
}

class _CrearLeerYEscribirScreenState extends State<CrearLeerYEscribirScreen> {
  double _aiTolerance = 2.0; // 1: Permisivo, 2: Equilibrado, 3: Estricto
  bool _consentChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EJERCICIO LEER Y ESCRIBIR',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label(text: 'INSTRUCCIÓN'),
            const _TextField(hint: 'Leer y repite la frase'),
            const SizedBox(height: 20),
            const _Label(text: 'IMAGEN DE REFERENCIA'),
            Row(
              children: [
                Expanded(
                    child: _MediaButton(
                        text: 'SUBIR ARCHIVO', icon: Icons.file_present_outlined)),
                const SizedBox(width: 16),
                Expanded(
                    child: _MediaButton(
                        text: 'TOMAR FOTO', icon: Icons.camera_alt_outlined)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Este audio será el que el usuario escuche para practicar.',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 20),
            const _Label(text: 'TEXTO OBJETIVO (NÁHUATL)'),
            const _TextField(hint: '¿Quen tinemi?'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Label(text: 'TOLERANCIA DE ESCRITURA (IA)'),
                _Badge(text: 'Normal', color: const Color(0xFFC7E8E0), textColor: AppColors.secundario),
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
                Text('PERMISIVO', style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text('EQUILIBRADO', style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text('ESTRICTO', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 32),
            _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (val) => setState(() => _consentChecked = val!)),
            const SizedBox(height: 32),
            const _SaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Pantalla: Crear Imágenes y Palabras (image_4.png centro)
class CrearImagenYPalabraScreen extends StatefulWidget {
  const CrearImagenYPalabraScreen({super.key});

  @override
  State<CrearImagenYPalabraScreen> createState() =>
      _CrearImagenYPalabraScreenState();
}

class _CrearImagenYPalabraScreenState extends State<CrearImagenYPalabraScreen> {
  int _correctIndex = 0; // 0 a 3
  bool _consentChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EJERCICIO IMÁGENES Y PALABRAS',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label(text: 'PALABRA / CONCEPTO'),
            const _TextField(hint: 'Tepetl'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Label(text: 'OPCIONES (4 IMÁGENES)'),
                const Text('MARCAR LA CORRECTA', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
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
              children: List.generate(4, (index) => _ImageOptionCard(
                index: index,
                isCorrect: _correctIndex == index,
                onCorrected: () => setState(() => _correctIndex = index),
              )),
            ),
            const SizedBox(height: 32),
            _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (val) => setState(() => _consentChecked = val!)),
            const SizedBox(height: 32),
            const _SaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Pantalla: Crear Completar Frase (image_4.png der.)
class CrearCompletarFraseScreen extends StatefulWidget {
  const CrearCompletarFraseScreen({super.key});

  @override
  State<CrearCompletarFraseScreen> createState() =>
      _CrearCompletarFraseScreenState();
}

class _CrearCompletarFraseScreenState extends State<CrearCompletarFraseScreen> {
  int _correctOptionIndex = 0; // 0 a 3
  bool _consentChecked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EJERCICIO COMPLETAR FRASE',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Label(text: 'FRASE CON HUECO'),
            _TextField(
              hint: 'Ej. Nehuatl ____ nahuatlahtolli.',
              maxLines: 4,
              suffixWidget: TextButton(
                  onPressed: () {},
                  child: const Text("USA '____' PARA EL HUECO",
                      style: TextStyle(color: AppColors.secundario, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Label(text: 'OPCIONES'),
                const Text('Selecciona la Correcta', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(
                4,
                (index) => _OptionFraseCard(
                      index: index,
                      isCorrect: _correctOptionIndex == index,
                      onSelected: () => setState(() => _correctOptionIndex = index),
                    )),
            const SizedBox(height: 24),
            const _Label(text: 'EXPLICACIÓN DEL ERROR (IA FEEDBACK)'),
            const _TextField(
                hint: 'Explica por qué las otras opciones son incorrectas para ayudar al modelo de IA...',
                maxLines: 4),
            const SizedBox(height: 32),
            _ConsentCheckbox(
                checked: _consentChecked,
                onChanged: (val) => setState(() => _consentChecked = val!)),
            const SizedBox(height: 32),
            const _SaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// Pantalla: Crear Escuchar y Hablar (Plantilla para que funcione la navegación)
class CrearEscucharYHablarScreen extends StatelessWidget {
  const CrearEscucharYHablarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EJERCICIO ESCUCHAR Y HABLAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.spatial_audio_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('Editor Manual de Escuchar y Hablar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
                'Aquí iría la interfaz para subir audio, texto objetivo y configurar la tolerancia del reconocimiento de voz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const Spacer(),
            const _SaveButton(),
          ],
        ),
      ),
    );
  }
}

// ─── COMPONENTES UI AUXILIARES (Nuevos y Reutilizables) ─────────────────────

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
        backgroundColor: const Color(0xFFFBFBFB),
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
  const _ImageOptionCard({required this.index, required this.isCorrect, required this.onCorrected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _MediaButton(text: 'SUBIR IMAGEN', icon: Icons.image_outlined),
              const SizedBox(height: 12),
              const _TextField(hint: 'Texto Alt (Ej. Montaña)'),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: isCorrect
                    ? const Icon(Icons.check_circle, color: AppColors.secundario, size: 24)
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
  const _OptionFraseCard({required this.index, required this.isCorrect, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    String text = index == 0 ? 'nitlahtoa' : 'Opción incorrecta ${index}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Radio(
            value: index,
            groupValue: isCorrect ? index : -1,
            onChanged: (val) => onSelected(),
            activeColor: AppColors.secundario,
          ),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: isCorrect ? Colors.black : Colors.grey, fontSize: 14))),
        ],
      ),
    
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;
  const _ConsentCheckbox({required this.checked, required this.onChanged});

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
                'Acepto que estos datos sean utilizados para mejorar el modelo de IA de la plataforma y optimizar el reconocimiento de voz.',
                style: TextStyle(color: AppColors.primario, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.save_outlined, color: Colors.white),
        label: const Text('Guardar Ejercicio',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secundario,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── COMPONENTES UI AUXILIARES (Originales Actualizados) ─────────────────────

class _EjercicioCardAdmin extends StatelessWidget {
  final String title, type;
  final VoidCallback onEdit;

  const _EjercicioCardAdmin({
    required this.title,
    required this.type,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.description_outlined, color: Colors.grey),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          type,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
              onPressed: onEdit,
            ),
            const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title, level, description, response, culturalContext;
  final Color accentColor;

  const _SuggestionCard({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
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
                  label:
                      const Text('Editar', style: TextStyle(color: Colors.grey)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
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
          )
        ],
      ),
    );
  }
}

class _InputGroup extends StatelessWidget {
  final String label, hint;
  final IconData? icon;
  const _InputGroup({required this.label, required this.hint, this.icon});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Label(text: label), _TextField(hint: hint, icon: icon)],
    );
  }
}

class _TextField extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final Widget? suffixWidget;
  final int maxLines;
  final TextEditingController? controller;

  const _TextField(
      {required this.hint,
      this.icon,
      this.suffixWidget,
      this.maxLines = 1,
      this.controller});

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
            fillColor: Colors.grey[50],
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

class _ModuleCardAdmin extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onTap;

  const _ModuleCardAdmin({
    required this.index,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secundario.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                  color: AppColors.secundario, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: const Text('12 Ejercicios',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
              onPressed: onTap,
            ),
            const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}

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
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String title, hintText;
  final VoidCallback onGenerate;

  const _InputCard(
      {required this.title, required this.hintText, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
          const _Label(text: 'TEMA O PALABRA CLAVE'),
          const _TextField(
              hint: 'ej. Animales de la selva', icon: Icons.edit_outlined),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGenerate,
              icon:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
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