import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principalesadmin/intentos_screen.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

const double _kBreakpoint = 700.0;

// ── Directorio principal ───────────────────────────────────────────────────────

class DirectorioUsuariosScreen extends StatefulWidget {
  const DirectorioUsuariosScreen({super.key});

  @override
  State<DirectorioUsuariosScreen> createState() =>
      _DirectorioUsuariosScreenState();
}

class _DirectorioUsuariosScreenState extends State<DirectorioUsuariosScreen> {
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _filtrados = [];
  bool _isLoading = true;
  final TextEditingController _buscador = TextEditingController();

  // Estadísticas generales
  int get _totalUsuarios => _todos.length;
  int get _xpPromedio => _todos.isEmpty
      ? 0
      : (_todos.fold<int>(0, (s, u) => s + (u['xp'] as int)) / _todos.length)
          .round();
  int get _enBasico =>
      _todos.where((u) => u['nivel_educativo'] == 'basico').length;
  int get _enAvanzado => _todos
      .where((u) =>
          u['nivel_educativo'] == 'intermedio' ||
          u['nivel_educativo'] == 'basico+')
      .length;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _buscador.addListener(_filtrar);
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').get();
      final lista = snap.docs.map((doc) {
        final d = doc.data();
        return {
          'uid': doc.id,
          'nombre': d['nombre'] ?? d['displayName'] ?? 'Sin nombre',
          'correo': d['correo'] ?? d['email'] ?? '',
          'xp': (d['xp'] as num?)?.toInt() ?? 0,
          'nivel_educativo': d['nivel_educativo'] ?? 'basico',
        };
      }).toList();

      lista.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));

      if (!mounted) return;
      setState(() {
        _todos = lista;
        _filtrados = lista;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando usuarios: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filtrar() {
    final q = _buscador.text.toLowerCase();
    setState(() {
      _filtrados = q.isEmpty
          ? _todos
          : _todos
              .where((u) =>
                  (u['nombre'] as String).toLowerCase().contains(q) ||
                  (u['correo'] as String).toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.secundario));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _kBreakpoint;

          Widget content = SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Text('Usuarios',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black)),
                const Text('Progreso y estadísticas de estudiantes',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 20),

                // ── Estadísticas generales ─────────────────────────────────────
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.4 : 1.55,
                  children: [
                    _KPICard(
                      titulo: 'Total Usuarios',
                      valor: '$_totalUsuarios',
                      icon: Icons.people_outline,
                      color: AppColors.secundario,
                      isDark: isDark,
                    ),
                    _KPICard(
                      titulo: 'XP Promedio',
                      valor: '$_xpPromedio',
                      icon: Icons.star_outline,
                      color: AppColors.amarillo1,
                      isDark: isDark,
                    ),
                    _KPICard(
                      titulo: 'Nivel Básico',
                      valor: '$_enBasico',
                      icon: Icons.school_outlined,
                      color: AppColors.azul1,
                      isDark: isDark,
                    ),
                    _KPICard(
                      titulo: 'Interm. y +',
                      valor: '$_enAvanzado',
                      icon: Icons.trending_up_outlined,
                      color: AppColors.naranja1,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Buscador ───────────────────────────────────────────────────
                TextField(
                  controller: _buscador,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o correo',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.fondoOscuroSecundario
                        : AppColors.fondoSecundario,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Acciones ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ACCIONES',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 1.1)),
                    Text('${_filtrados.length} usuarios',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.refresh,
                        label: 'Recargar',
                        iconColor: AppColors.secundario,
                        isDark: isDark,
                        onTap: _cargarUsuarios,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.download_outlined,
                        label: 'Exportar',
                        iconColor: AppColors.azul1,
                        isDark: isDark,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.bar_chart_outlined,
                        label: 'Reporte',
                        iconColor: AppColors.naranja1,
                        isDark: isDark,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Lista de usuarios ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Directorio de Usuarios',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black)),
                    Text('${_filtrados.length} resultados',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),

                _filtrados.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('No se encontraron usuarios.',
                              style: TextStyle(color: Colors.grey[400])),
                        ),
                      )
                    : isWide
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtrados.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.8,
                            ),
                            itemBuilder: (context, i) =>
                                _UserCard(usuario: _filtrados[i], isDark: isDark),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtrados.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _UserCard(usuario: _filtrados[i], isDark: isDark),
                          ),
                const SizedBox(height: 20),
              ],
            ),
          );

          if (isWide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }
}

// ── Perfil de usuario ──────────────────────────────────────────────────────────

class PerfilUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PerfilUsuarioScreen({super.key, required this.usuario});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  List<Map<String, dynamic>> _cursos = [];
  bool _isLoading = true;
  int _totalLecciones = 0;
  bool _adminTieneAccesoSistema = false;

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
    _cargarAccesoAdmin();
  }

  Future<void> _cargarAccesoAdmin() async {
    try {
      final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .get();
      final userData = userDoc.data() ?? {};
      setState(() {
        _adminTieneAccesoSistema = (userData['sistema'] as bool?) ?? false;
      });
    } catch (e) {
      debugPrint('Error cargando acceso admin: $e');
    }
  }

  Map<String, Map<String, dynamic>> _parseLecciones(Map<String, dynamic> data) {
    final leccionesMap = (data['lecciones'] as Map<String, dynamic>?) ?? {};
    final leccionesDetalle = <String, Map<String, dynamic>>{};
    leccionesMap.forEach((leccionId, leccionData) {
      if (leccionData is Map<String, dynamic>) {
        leccionesDetalle[leccionId] = {
          'aciertos': (leccionData['aciertos'] as num?)?.toInt() ?? 0,
          'completada': leccionData['completada'] as bool? ?? false,
          'fecha': leccionData['fecha'],
          'precision': (leccionData['precision'] as num?)?.toInt() ?? 0,
          'total': (leccionData['total'] as num?)?.toInt() ?? 0,
        };
      }
    });
    return leccionesDetalle;
  }

  Future<void> _cargarProgreso() async {
    final uid = widget.usuario['uid'] as String;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('progreso_cursos')
          .get();

      if (snap.docs.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final ids = snap.docs.map((d) => d.id).toList();
      final cursos = await CursosService.fetchCursosByIds(ids);
      final cursoMap = {for (final c in cursos) c.id: c};

      int total = 0;
      final lista = snap.docs.map((doc) {
        final data = doc.data();
        final lecciones =
            List<String>.from(data['leccionesCompletadas'] ?? []);
        total += lecciones.length;
        final curso = cursoMap[doc.id];
        final pct =
            (data['porcentajeTotal'] as num?)?.toDouble() ?? 0.0;
        return {
          'cursoId': doc.id,
          'titulo': curso?.titulo ?? 'Curso desconocido',
          'creadoPor': curso?.creadoPor ?? '',
          'porcentaje': pct,
          'leccionesCompletadas': lecciones.length,
          'xpGanado': (data['xpHoy'] as num?)?.toInt() ?? 0,
          'fechaUltimaXP': data['fechaUltimaXP'] as String? ?? '',
          'fechaInscripcion': data['fecha_inscripcion'],
          'leccionesDetalles': _parseLecciones(data),
          'completado': pct >= 1.0,
        };
      }).toList();

      lista.sort((a, b) =>
          (b['porcentaje'] as double).compareTo(a['porcentaje'] as double));

      if (!mounted) return;
      setState(() {
        _cursos = lista;
        _totalLecciones = total;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando progreso: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final u = widget.usuario;
    final xp = u['xp'] as int? ?? 0;
    final nivel = u['nivel_educativo'] as String? ?? 'basico';

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PERFIL DE USUARIO',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.secundario))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= _kBreakpoint;

                Widget scrollContent = SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // ── Cabecera ─────────────────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor:
                                  AppColors.secundario.withValues(alpha: 0.15),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _initiales(u['nombre'] as String),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secundario),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(u['nombre'] as String,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black)),
                            const SizedBox(height: 4),
                            Text(u['correo'] as String,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 14)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.secundario.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _labelNivel(nivel),
                                style: const TextStyle(
                                  color: AppColors.secundario,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Stats ─────────────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.fondoOscuroSecundario
                              : AppColors.fondoSecundario,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              value: '$xp',
                              label: 'XP Total',
                              icon: Icons.star_outline,
                              color: AppColors.amarillo1,
                            ),
                            _Divisor(),
                            _StatItem(
                              value: '$_totalLecciones',
                              label: 'Lecciones',
                              icon: Icons.menu_book_outlined,
                              color: AppColors.secundario,
                            ),
                            _Divisor(),
                            _StatItem(
                              value: '${_cursos.length}',
                              label: 'Cursos',
                              icon: Icons.layers_outlined,
                              color: AppColors.azul1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Progreso en cursos ────────────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Progreso en Cursos',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black)),
                      ),
                      const SizedBox(height: 16),

                      _cursos.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Este usuario no tiene cursos inscritos.',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _cursos.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, i) {
                                final c = _cursos[i];
                                final pct = c['porcentaje'] as double;
                                final completado = c['completado'] as bool;
                                final color = completado
                                    ? AppColors.secundario
                                    : AppColors.naranja1;
                                final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                                final creadoPor = c['creadoPor'] as String;
                                final esAdminDelCurso = creadoPor == adminUid || 
                                    (_adminTieneAccesoSistema && creadoPor == 'sistema');
                                return _CourseProgressCard(
                                  title: c['titulo'] as String,
                                  progressText: completado
                                      ? 'Completado · ${c['leccionesCompletadas']} lecciones'
                                      : '${c['leccionesCompletadas']} lecciones completadas · ${(pct * 100).toInt()}%',
                                  progressValue: pct,
                                  statusText: completado ? 'Finalizado' : 'En curso',
                                  statusColor: color,
                                  iconColor: color,
                                  esAdminDelCurso: esAdminDelCurso,
                                  xpGanado: c['xpGanado'] as int? ?? 0,
                                  fechaUltimaXP: c['fechaUltimaXP'] as String? ?? '',
                                  fechaInscripcion: c['fechaInscripcion'],
                                  leccionesDetalles: c['leccionesDetalles'] as Map<String, Map<String, dynamic>>? ?? {},
                                  onTap: esAdminDelCurso
                                      ? () => Navigator.push(
                                            ctx,
                                            MaterialPageRoute(
                                              builder: (_) => IntentosScreen(
                                                uid: widget.usuario['uid'] as String,
                                                nombreUsuario: widget.usuario['nombre'] as String,
                                                cursoId: c['cursoId'] as String,
                                                cursoTitulo: c['titulo'] as String,
                                              ),
                                            ),
                                          )
                                      : null,
                                );
                              },
                            ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );

                if (isWide) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: scrollContent,
                    ),
                  );
                }

                return scrollContent;
              },
            ),
    );
  }

  String _initiales(String nombre) {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  String _labelNivel(String nivel) {
    switch (nivel) {
      case 'basico':
        return 'Nivel Básico';
      case 'basico+':
        return 'Nivel Básico+';
      case 'intermedio':
        return 'Nivel Intermedio';
      case 'avanzado':
        return 'Nivel Avanzado';
      default:
        return nivel;
    }
  }
}

// ── Componentes ────────────────────────────────────────────────────────────────

class _KPICard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _KPICard({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(valor,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          Text(titulo,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final bool isDark;

  const _UserCard({required this.usuario, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final nivel = usuario['nivel_educativo'] as String? ?? 'basico';
    final xp = usuario['xp'] as int? ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                PerfilUsuarioScreen(usuario: usuario)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  AppColors.secundario.withValues(alpha: 0.15),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _initiales(usuario['nombre'] as String),
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secundario,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(usuario['nombre'] as String,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 2),
                  Text(usuario['correo'] as String,
                      style: TextStyle(
                          color: isDark
                              ? AppColors.textoClaro
                              : AppColors.secundario,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _NivelBadge(nivel: nivel),
                      const SizedBox(width: 8),
                      Icon(Icons.star_outline,
                          size: 13, color: AppColors.amarillo1),
                      const SizedBox(width: 3),
                      Text('$xp XP',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDark
                    ? AppColors.textoSecundario40
                    : AppColors.textoSecundario20),
          ],
        ),
      ),
    );
  }

  String _initiales(String nombre) {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }
}

class _NivelBadge extends StatelessWidget {
  final String nivel;
  const _NivelBadge({required this.nivel});

  @override
  Widget build(BuildContext context) {
    final color = switch (nivel) {
      'intermedio' => AppColors.naranja1,
      'basico+' => AppColors.azul1,
      _ => AppColors.secundario,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(nivel,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppColors.extra120);
}

class _CourseProgressCard extends StatefulWidget {
  final String title;
  final String progressText;
  final double progressValue;
  final String statusText;
  final Color statusColor;
  final Color iconColor;
  final bool esAdminDelCurso;
  final VoidCallback? onTap;
  final int xpGanado;
  final String fechaUltimaXP;
  final dynamic fechaInscripcion;
  final Map<String, Map<String, dynamic>> leccionesDetalles;

  const _CourseProgressCard({
    required this.title,
    required this.progressText,
    required this.progressValue,
    required this.statusText,
    required this.statusColor,
    required this.iconColor,
    this.esAdminDelCurso = false,
    this.onTap,
    this.xpGanado = 0,
    this.fechaUltimaXP = '',
    this.fechaInscripcion,
    this.leccionesDetalles = const {},
  });

  @override
  State<_CourseProgressCard> createState() => _CourseProgressCardState();
}

class _CourseProgressCardState extends State<_CourseProgressCard> {
  bool _expandida = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: widget.esAdminDelCurso
                  ? AppColors.secundario.withValues(alpha: 0.4)
                  : isDark
                      ? AppColors.extraOscuro120
                      : AppColors.extra120),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.book_outlined, color: widget.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.statusText,
                      style: TextStyle(
                          color: widget.statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                if (widget.esAdminDelCurso) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _expandida = !_expandida),
                    child: Icon(
                      _expandida ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: AppColors.secundario,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock_outline,
                      size: 16, color: AppColors.textoSecundario40),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(widget.progressText,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: widget.progressValue,
                backgroundColor:
                    isDark ? AppColors.extraOscuro120 : AppColors.extra120,
                color: widget.statusColor,
                minHeight: 8,
              ),
            ),
            if (widget.esAdminDelCurso && _expandida) ...[
              const SizedBox(height: 16),
              // Información resumida
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.fondoOscuro : AppColors.fondoSecundario,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.fechaInscripcion != null) ...[
                      _InfoRow(
                        label: 'Inscripción',
                        value: _formatDate(widget.fechaInscripcion),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.xpGanado > 0) ...[
                      _InfoRow(
                        label: 'XP Hoy',
                        value: '${widget.xpGanado} XP',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.fechaUltimaXP.isNotEmpty) ...[
                      _InfoRow(
                        label: 'Última XP',
                        value: widget.fechaUltimaXP,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              // Detalles de lecciones
              if (widget.leccionesDetalles.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Detalles de Lecciones',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.leccionesDetalles.entries.map((entry) {
                  final leccionId = entry.key;
                  final datos = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: datos['completada'] as bool
                            ? AppColors.secundario.withValues(alpha: 0.1)
                            : AppColors.naranja1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                datos['completada'] as bool
                                    ? Icons.check_circle
                                    : Icons.pending,
                                size: 16,
                                color: datos['completada'] as bool
                                    ? AppColors.secundario
                                    : AppColors.naranja1,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                leccionId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${datos['precision']}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secundario,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Aciertos: ${datos['aciertos']}/${datos['total']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Fecha: ${_formatDate(datos['fecha'])}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
            if (widget.esAdminDelCurso) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.bar_chart_outlined,
                      size: 13, color: AppColors.secundario),
                  const SizedBox(width: 4),
                  Text('Ver intentos de ejercicios',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secundario,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    if (dateValue is String) return dateValue;
    if (dateValue is Timestamp) {
      final date = dateValue.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }
}
