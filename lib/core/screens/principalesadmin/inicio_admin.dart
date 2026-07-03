import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/services/admin_stats_service.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class InicioAdminScreen extends StatefulWidget {
  const InicioAdminScreen({super.key});

  @override
  State<InicioAdminScreen> createState() => _InicioAdminScreenState();
}

class _InicioAdminScreenState extends State<InicioAdminScreen> {
  late final Future<AdminStats> _statsFuture;
  late final Stream<List<CursoModel>> _cursosRecientesStream;
  late final Stream<List<CursoModel>> _cursosSistemaStream;

  String _filtroRecientes = 'Semana';
  bool _esSistema = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _statsFuture           = AdminStatsService.cargar(uid);
    _cursosRecientesStream = CursosService.streamCursos();
    _cursosSistemaStream   = CursosService.streamCursosOficiales();
    _cargarFlagSistema(uid);
  }

  Future<void> _cargarFlagSistema(String uid) async {
    if (uid.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data     = doc.data() ?? {};
    final rolAdmin = (data['rol'] as String? ?? '') == 'admin';
    final sistema  = data['sistema'] as bool? ?? false;
    if (mounted) setState(() => _esSistema = rolAdmin && sistema);
  }

  @override
  Widget build(BuildContext context) {
    final sw     = MediaQuery.of(context).size.width;
    final isWide = sw > 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      child: isWide
          ? _wideLayout()
          : _narrowLayout(),
    );
  }

  // ── Layout ancho ──────────────────────────────────────────────────────────────

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: KPIs + cursos sistema
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKPIs(),
              if (_esSistema) ...[
                const SizedBox(height: 28),
                _buildCursosSistema(),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Columna derecha: cursos recientes
        Expanded(
          flex: 4,
          child: _buildCursosRecientes(),
        ),
      ],
    );
  }

  // ── Layout estrecho ───────────────────────────────────────────────────────────

  Widget _narrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKPIs(),
        const SizedBox(height: 24),
        _buildCursosRecientes(),
        if (_esSistema) ...[
          const SizedBox(height: 24),
          _buildCursosSistema(),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // ── KPI section ────────────────────────────────────────────────────────────

  Widget _buildKPIs() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snap) {
        final loading = !snap.hasData && !snap.hasError;
        final stats   = snap.data;
        String fmt(int? v) => loading ? '—' : '${v ?? 0}';

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _TarjetaKPI(
                    label: 'CURSOS CREADOS',
                    valor: fmt(stats?.cursosCreados),
                    icon: Icons.school_outlined,
                    iconColor: AppColors.primario,
                    loading: loading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TarjetaKPI(
                    label: 'LECCIONES',
                    valor: fmt(stats?.leccionesCreadas),
                    icon: Icons.menu_book_outlined,
                    iconColor: Colors.orange,
                    loading: loading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TarjetaKPI(
                    label: 'USUARIOS ACTIVOS',
                    valor: fmt(stats?.usuariosActivos),
                    icon: Icons.people_outline,
                    iconColor: Colors.blue,
                    subtitulo: 'últimos 30 días',
                    loading: loading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TarjetaKPI(
                    label: 'USUARIOS NUEVOS',
                    valor: fmt(stats?.usuariosNuevos),
                    icon: Icons.person_add_outlined,
                    iconColor: Colors.green,
                    subtitulo: 'últimos 7 días',
                    loading: loading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TarjetaProgresoKPI(
              label: 'TASA DE COMPLETACIÓN',
              valor: loading
                  ? '—'
                  : '${((stats?.tasaCompletacion ?? 0) * 100).toStringAsFixed(0)}%',
              progreso: loading ? 0.0 : (stats?.tasaCompletacion ?? 0),
            ),
          ],
        );
      },
    );
  }

  // ── Cursos recientes ──────────────────────────────────────────────────────────

  Widget _buildCursosRecientes() {
    final dias   = _filtroRecientes == 'Semana' ? 7 : 30;
    final cutoff = DateTime.now().subtract(Duration(days: dias));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'CURSOS RECIENTES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            ...['Semana', 'Mes'].map((f) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: () => setState(() => _filtroRecientes = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _filtroRecientes == f
                        ? AppColors.secundario
                        : AppColors.secundario.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          _filtroRecientes == f ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<CursoModel>>(
          stream: _cursosRecientesStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snap.hasError) {
              return _MensajeVacio(
                icon: Icons.error_outline,
                texto: 'Error al cargar cursos',
                color: Colors.red,
              );
            }

            final todos  = snap.data ?? [];
            final cursos = todos
                .where((c) =>
                    c.creadoEn != null && c.creadoEn!.isAfter(cutoff))
                .toList()
              ..sort((a, b) => b.creadoEn!.compareTo(a.creadoEn!));

            if (cursos.isEmpty) {
              return _MensajeVacio(
                icon: Icons.inbox_outlined,
                texto: 'Sin cursos en la última '
                    '${_filtroRecientes == 'Semana' ? 'semana' : 'mes'}',
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cursos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CursoCard(curso: cursos[i]),
            );
          },
        ),
      ],
    );
  }

  // ── Cursos del sistema (solo admin + sistema:true) ────────────────────────────

  Widget _buildCursosSistema() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.verified_outlined, size: 14, color: AppColors.secundario),
            SizedBox(width: 6),
            Text(
              'CURSOS DEL SISTEMA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<CursoModel>>(
          stream: _cursosSistemaStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snap.hasError) {
              return _MensajeVacio(
                icon: Icons.error_outline,
                texto: 'Error al cargar cursos del sistema',
                color: Colors.red,
              );
            }

            final cursos = snap.data ?? [];
            if (cursos.isEmpty) {
              return _MensajeVacio(
                icon: Icons.school_outlined,
                texto: 'No hay cursos del sistema aún',
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cursos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CursoCard(
                curso: cursos[i],
                esSistema: true,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── KPI Cards ─────────────────────────────────────────────────────────────────

class _TarjetaKPI extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color iconColor;
  final String? subtitulo;
  final bool loading;

  const _TarjetaKPI({
    required this.label,
    required this.valor,
    required this.icon,
    required this.iconColor,
    this.subtitulo,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              valor,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          if (subtitulo != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitulo!,
              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaProgresoKPI extends StatelessWidget {
  final String label;
  final String valor;
  final double progreso;

  const _TarjetaProgresoKPI({
    required this.label,
    required this.valor,
    required this.progreso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                valor,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.secundario,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Curso Card ────────────────────────────────────────────────────────────────

class _CursoCard extends StatelessWidget {
  final CursoModel curso;
  final bool esSistema;

  const _CursoCard({required this.curso, this.esSistema = false});

  Color get _nivelColor {
    switch (curso.nivel.toLowerCase()) {
      case 'avanzado':   return Colors.redAccent;
      case 'intermedio': return Colors.orangeAccent;
      default:           return Colors.greenAccent;
    }
  }

  String get _nivelLetra {
    switch (curso.nivel.toLowerCase()) {
      case 'avanzado':   return 'A';
      case 'intermedio': return 'I';
      default:           return 'B';
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7)  return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecor(context),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _nivelColor.withValues(alpha: 0.2),
              child: Text(
                _nivelLetra,
                style: TextStyle(
                  color: _nivelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    curso.titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (esSistema) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secundario.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'sistema',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secundario,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              curso.creadoEn != null
                  ? 'Creado ${_formatDate(curso.creadoEn!)}'
                  : curso.descripcion,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$value: ${curso.titulo}')),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Editar',
                  child: Row(children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'Eliminar',
                  child: Row(children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Eliminar',
                        style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _StatusBadge(publicado: curso.publicado),
                const SizedBox(width: 8),
                if (curso.leccionesCount > 0) ...[
                  Icon(Icons.menu_book_outlined,
                      size: 13, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${curso.leccionesCount} lec.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
                const Spacer(),
                if (curso.suscritosCount > 0) ...[
                  Icon(Icons.people_outline,
                      size: 13, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${curso.suscritosCount}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool publicado;
  const _StatusBadge({required this.publicado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: publicado
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : Colors.blueAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 3,
            backgroundColor: publicado ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 6),
          Text(
            publicado ? 'Publicado' : 'Borrador',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: publicado ? Colors.green[700] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────────

class _MensajeVacio extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color? color;

  const _MensajeVacio({required this.icon, required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _boxDecor(context),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: color ?? Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              texto,
              style: TextStyle(
                  color: color ?? Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared decoration ─────────────────────────────────────────────────────────

BoxDecoration _boxDecor(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 2,
        offset: const Offset(3, 3),
      ),
    ],
  );
}
