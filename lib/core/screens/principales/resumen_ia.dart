import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ResumenIAScreen extends StatefulWidget {
  const ResumenIAScreen({super.key});

  @override
  State<ResumenIAScreen> createState() => _ResumenIAScreenState();
}

class _ResumenIAScreenState extends State<ResumenIAScreen> {
  bool _isLoading = true;

  String _nombre = 'Usuario';
  String _nivelEducativo = 'basico';
  int _xp = 0;
  int _rachaActual = 0;

  int _precisionGlobal = 0;
  int _tiempoPromedioSegundos = 0;
  int _totalLeccionesCompletadas = 0;
  int _totalAciertos = 0;
  int _totalErrores = 0;

  List<Map<String, dynamic>> _cursos = [];
  List<Map<String, dynamic>> _historialGrafica = []; // last 10, asc
  List<Map<String, dynamic>> _historialLista = [];   // last 5, desc

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // ── 1. User document ────────────────────────────────────────────────────
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final ud = userDoc.data() ?? {};
      final nombre = (ud['nombre'] ?? ud['displayName'] ?? 'Usuario') as String;
      final nivel = (ud['nivel_educativo'] as String?) ?? 'basico';
      final xp = (ud['xp'] as num?)?.toInt() ?? 0;
      final racha = ((ud['rachaActual'] ?? ud['racha_actual']) as num?)?.toInt() ?? 0;

      // ── 2. Progreso por curso ───────────────────────────────────────────────
      final cursosSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('progreso_cursos')
          .get();

      final cursoIds = cursosSnap.docs.map((d) => d.id).toList();
      final cursoModels = await CursosService.fetchCursosByIds(cursoIds);
      final cursoTitulos = {for (final c in cursoModels) c.id: c.titulo};

      final cursos = cursosSnap.docs.map((doc) {
        final d = doc.data();
        final pct = (d['porcentajeTotal'] as num?)?.toDouble() ?? 0.0;
        final completadas =
            List<String>.from(d['leccionesCompletadas'] ?? []).length;
        return {
          'titulo': cursoTitulos[doc.id] ?? doc.id,
          'porcentaje': pct,
          'leccionesCompletadas': completadas,
        };
      }).toList()
        ..sort((a, b) =>
            (b['porcentaje'] as double).compareTo(a['porcentaje'] as double));

      // ── 3. Historial de todos los cursos ────────────────────────────────────
      int totalAciertos = 0, totalErrores = 0;
      int totalTiempo = 0, countTiempo = 0;
      int totalLecciones = 0;
      final allHistorial = <Map<String, dynamic>>[];

      for (final cursoDoc in cursosSnap.docs) {
        final d = cursoDoc.data();
        totalLecciones +=
            List<String>.from(d['leccionesCompletadas'] ?? []).length;

        final hSnap = await cursoDoc.reference
            .collection('historial')
            .orderBy('fecha', descending: false)
            .get();

        for (final h in hSnap.docs) {
          final hd = h.data();
          final aciertos = (hd['aciertos'] as num?)?.toInt() ?? 0;
          final total = (hd['total'] as num?)?.toInt() ?? 0;
          totalAciertos += aciertos;
          totalErrores += (total - aciertos).clamp(0, total);
          final tiempo = (hd['tiempoSegundos'] as num?)?.toInt() ?? 0;
          if (tiempo > 0) {
            totalTiempo += tiempo;
            countTiempo++;
          }
          allHistorial.add(Map<String, dynamic>.from(hd));
        }
      }

      // Sort by fecha ascending (for chart)
      allHistorial.sort((a, b) {
        final fa = a['fecha'];
        final fb = b['fecha'];
        if (fa is Timestamp && fb is Timestamp) {
          if (fa.seconds != fb.seconds) {
            return fa.seconds.compareTo(fb.seconds);
          }
          return fa.nanoseconds.compareTo(fb.nanoseconds);
        }
        return 0;
      });

      final totalEj = totalAciertos + totalErrores;
      final precisionGlobal =
          totalEj > 0 ? (totalAciertos / totalEj * 100).round() : 0;
      final tiempoPromedio =
          countTiempo > 0 ? totalTiempo ~/ countTiempo : 0;

      final grafica = allHistorial.length > 10
          ? allHistorial.sublist(allHistorial.length - 10)
          : allHistorial;
      final lista = allHistorial.reversed.take(5).toList();

      if (!mounted) return;
      setState(() {
        _nombre = nombre;
        _nivelEducativo = nivel;
        _xp = xp;
        _rachaActual = racha;
        _precisionGlobal = precisionGlobal;
        _tiempoPromedioSegundos = tiempoPromedio;
        _totalLeccionesCompletadas = totalLecciones;
        _totalAciertos = totalAciertos;
        _totalErrores = totalErrores;
        _cursos = cursos;
        _historialGrafica = grafica;
        _historialLista = lista;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ResumenIAScreen._cargarDatos error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.secundario),
        ),
      );
    }

    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 800;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      body: SafeArea(
        child: isWide
            ? _WideLayout(
                isDark: isDark,
                nombre: _nombre,
                nivelEducativo: _nivelEducativo,
                xp: _xp,
                rachaActual: _rachaActual,
                precisionGlobal: _precisionGlobal,
                tiempoPromedioSegundos: _tiempoPromedioSegundos,
                totalLeccionesCompletadas: _totalLeccionesCompletadas,
                totalAciertos: _totalAciertos,
                totalErrores: _totalErrores,
                cursos: _cursos,
                historialGrafica: _historialGrafica,
                historialLista: _historialLista,
                onRecargar: _cargarDatos,
              )
            : _MobileLayout(
                isDark: isDark,
                nombre: _nombre,
                nivelEducativo: _nivelEducativo,
                xp: _xp,
                rachaActual: _rachaActual,
                precisionGlobal: _precisionGlobal,
                tiempoPromedioSegundos: _tiempoPromedioSegundos,
                totalLeccionesCompletadas: _totalLeccionesCompletadas,
                totalAciertos: _totalAciertos,
                totalErrores: _totalErrores,
                cursos: _cursos,
                historialGrafica: _historialGrafica,
                historialLista: _historialLista,
                onRecargar: _cargarDatos,
              ),
      ),
    );
  }
}

// ── Layouts ───────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final bool isDark;
  final String nombre;
  final String nivelEducativo;
  final int xp;
  final int rachaActual;
  final int precisionGlobal;
  final int tiempoPromedioSegundos;
  final int totalLeccionesCompletadas;
  final int totalAciertos;
  final int totalErrores;
  final List<Map<String, dynamic>> cursos;
  final List<Map<String, dynamic>> historialGrafica;
  final List<Map<String, dynamic>> historialLista;
  final VoidCallback onRecargar;

  const _MobileLayout({
    required this.isDark,
    required this.nombre,
    required this.nivelEducativo,
    required this.xp,
    required this.rachaActual,
    required this.precisionGlobal,
    required this.tiempoPromedioSegundos,
    required this.totalLeccionesCompletadas,
    required this.totalAciertos,
    required this.totalErrores,
    required this.cursos,
    required this.historialGrafica,
    required this.historialLista,
    required this.onRecargar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TarjetaPerfilSaludo(
            isDark: isDark,
            nombre: nombre,
            nivelEducativo: nivelEducativo,
            xp: xp,
            rachaActual: rachaActual,
            onRecargar: onRecargar,
          ),
          const SizedBox(height: 20),
          _SeccionKPIs(
            isDark: isDark,
            precisionGlobal: precisionGlobal,
            tiempoPromedioSegundos: tiempoPromedioSegundos,
            totalLecciones: totalLeccionesCompletadas,
            rachaActual: rachaActual,
          ),
          const SizedBox(height: 20),
          _SeccionGraficaMejora(
            isDark: isDark,
            historial: historialGrafica,
          ),
          const SizedBox(height: 20),
          _SeccionAvanceCursos(isDark: isDark, cursos: cursos),
          const SizedBox(height: 20),
          _SeccionHistorialIntentos(
              isDark: isDark, historial: historialLista),
          const SizedBox(height: 20),
          _SeccionConsejo(isDark: isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final bool isDark;
  final String nombre;
  final String nivelEducativo;
  final int xp;
  final int rachaActual;
  final int precisionGlobal;
  final int tiempoPromedioSegundos;
  final int totalLeccionesCompletadas;
  final int totalAciertos;
  final int totalErrores;
  final List<Map<String, dynamic>> cursos;
  final List<Map<String, dynamic>> historialGrafica;
  final List<Map<String, dynamic>> historialLista;
  final VoidCallback onRecargar;

  const _WideLayout({
    required this.isDark,
    required this.nombre,
    required this.nivelEducativo,
    required this.xp,
    required this.rachaActual,
    required this.precisionGlobal,
    required this.tiempoPromedioSegundos,
    required this.totalLeccionesCompletadas,
    required this.totalAciertos,
    required this.totalErrores,
    required this.cursos,
    required this.historialGrafica,
    required this.historialLista,
    required this.onRecargar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          SizedBox(
            width: 520,
            child: Column(
              children: [
                _TarjetaPerfilSaludo(
                  isDark: isDark,
                  nombre: nombre,
                  nivelEducativo: nivelEducativo,
                  xp: xp,
                  rachaActual: rachaActual,
                  onRecargar: onRecargar,
                ),
                const SizedBox(height: 16),
                _SeccionKPIs(
                  isDark: isDark,
                  precisionGlobal: precisionGlobal,
                  tiempoPromedioSegundos: tiempoPromedioSegundos,
                  totalLecciones: totalLeccionesCompletadas,
                  rachaActual: rachaActual,
                ),
                const SizedBox(height: 16),
                _SeccionGraficaMejora(
                  isDark: isDark,
                  historial: historialGrafica,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SeccionAvanceCursos(isDark: isDark, cursos: cursos),
                const SizedBox(height: 20),
                _SeccionHistorialIntentos(
                    isDark: isDark, historial: historialLista),
                const SizedBox(height: 20),
                _SeccionConsejo(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta: Perfil + Saludo ──────────────────────────────────────────────────

class _TarjetaPerfilSaludo extends StatelessWidget {
  final bool isDark;
  final String nombre;
  final String nivelEducativo;
  final int xp;
  final int rachaActual;
  final VoidCallback onRecargar;

  const _TarjetaPerfilSaludo({
    required this.isDark,
    required this.nombre,
    required this.nivelEducativo,
    required this.xp,
    required this.rachaActual,
    required this.onRecargar,
  });

  String _initiales(String n) {
    final parts = n.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  String _labelNivel(String nivel) {
    switch (nivel) {
      case 'basico+':
        return 'Básico+';
      case 'intermedio':
        return 'Intermedio';
      case 'avanzado':
        return 'Avanzado';
      default:
        return 'Básico';
    }
  }

  Color _colorNivel(String nivel) {
    switch (nivel) {
      case 'basico+':
        return AppColors.azul1;
      case 'intermedio':
        return AppColors.naranja1;
      case 'avanzado':
        return AppColors.amarillo1;
      default:
        return AppColors.secundario;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = nombre.split(' ').first;
    final nivelColor = _colorNivel(nivelEducativo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isDark
                    ? AppColors.extraOscuro120
                    : AppColors.extra120,
                child: Text(
                  _initiales(nombre),
                  style: const TextStyle(
                    color: AppColors.primario,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              if (rachaActual > 0)
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.naranja1,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¡Cualli tonalli, $firstName!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          // Nivel badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: nivelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: nivelColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_outlined, size: 13, color: nivelColor),
                const SizedBox(width: 5),
                Text(
                  'Nivel ${_labelNivel(nivelEducativo)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: nivelColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // XP + racha row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.star_rounded,
                iconColor: AppColors.amarillo1,
                label: '$xp XP',
              ),
              if (rachaActual > 0) ...[
                const SizedBox(width: 10),
                _StatChip(
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.naranja1,
                  label: '$rachaActual días',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatChip(
      {required this.icon,
      required this.iconColor,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección: KPIs ─────────────────────────────────────────────────────────────

class _SeccionKPIs extends StatelessWidget {
  final bool isDark;
  final int precisionGlobal;
  final int tiempoPromedioSegundos;
  final int totalLecciones;
  final int rachaActual;

  const _SeccionKPIs({
    required this.isDark,
    required this.precisionGlobal,
    required this.tiempoPromedioSegundos,
    required this.totalLecciones,
    required this.rachaActual,
  });

  String _formatTiempo(int s) {
    if (s == 0) return '—';
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final sec = s % 60;
    return sec == 0 ? '${m}m' : '${m}m ${sec}s';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _KPICard(
          icon: Icons.analytics_outlined,
          iconColor: AppColors.secundario,
          value: '$precisionGlobal%',
          label: 'Precisión global',
          isDark: isDark,
        ),
        _KPICard(
          icon: Icons.timer_outlined,
          iconColor: AppColors.azul1,
          value: _formatTiempo(tiempoPromedioSegundos),
          label: 'Tiempo promedio',
          isDark: isDark,
        ),
        _KPICard(
          icon: Icons.menu_book_outlined,
          iconColor: AppColors.amarillo1,
          value: '$totalLecciones',
          label: 'Lecciones',
          isDark: isDark,
        ),
        _KPICard(
          icon: Icons.local_fire_department,
          iconColor: AppColors.naranja1,
          value: rachaActual > 0 ? '$rachaActual días' : '—',
          label: 'Racha actual',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _KPICard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
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
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Sección: Gráfica de mejora ────────────────────────────────────────────────

class _SeccionGraficaMejora extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> historial;

  const _SeccionGraficaMejora(
      {required this.isDark, required this.historial});

  String _formatFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      final d = fecha.toDate();
      return '${d.day}/${d.month}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Evolución de precisión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'últimos ${historial.length} intentos',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.fondoOscuroSecundario
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: historial.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Completa lecciones para ver tu progreso.',
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 130,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: historial.map((h) {
                          final precision =
                              (h['precision'] as num?)?.toInt() ?? 0;
                          final barH = (precision / 100) * 100.0;
                          final color = precision >= 70
                              ? AppColors.secundario
                              : precision >= 40
                                  ? AppColors.naranja1
                                  : AppColors.rojo1;
                          final fecha = _formatFecha(h['fecha']);
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: barH.clamp(4.0, 100.0),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$precision%',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey[500]),
                                ),
                                if (fecha.isNotEmpty)
                                  Text(
                                    fecha,
                                    style: TextStyle(
                                        fontSize: 7,
                                        color: Colors.grey[400]),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LeyendaItem(
                            color: AppColors.secundario, label: '≥70%'),
                        const SizedBox(width: 14),
                        _LeyendaItem(
                            color: AppColors.naranja1, label: '40–69%'),
                        const SizedBox(width: 14),
                        _LeyendaItem(
                            color: AppColors.rojo1, label: '<40%'),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LeyendaItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}

// ── Sección: Avance por curso ─────────────────────────────────────────────────

class _SeccionAvanceCursos extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> cursos;

  const _SeccionAvanceCursos(
      {required this.isDark, required this.cursos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avance por unidad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (cursos.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.fondoOscuroSecundario
                  : AppColors.fondoSecundario,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'No tienes cursos suscritos aún.',
                style:
                    TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
          )
        else
          ...cursos.map((c) {
            final pct = (c['porcentaje'] as double);
            final completadas = c['leccionesCompletadas'] as int;
            final completado = pct >= 1.0;
            final color =
                completado ? AppColors.secundario : AppColors.azul1;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.fondoOscuroSecundario
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 2,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c['titulo'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          completado
                              ? 'Completado'
                              : '${(pct * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor:
                          color.withValues(alpha: 0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completadas lecci${completadas == 1 ? 'ón' : 'ones'} completada${completadas == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// ── Sección: Historial de intentos ────────────────────────────────────────────

class _SeccionHistorialIntentos extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> historial;

  const _SeccionHistorialIntentos(
      {required this.isDark, required this.historial});

  String _formatFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      final d = fecha.toDate();
      return '${d.day}/${d.month}/${d.year}';
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de intentos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.fondoOscuroSecundario
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: historial.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aún no hay intentos registrados.',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                )
              : Column(
                  children: historial.asMap().entries.map((entry) {
                    final h = entry.value;
                    final isLast = entry.key == historial.length - 1;
                    final precision =
                        (h['precision'] as num?)?.toInt() ?? 0;
                    final aciertos =
                        (h['aciertos'] as num?)?.toInt() ?? 0;
                    final total =
                        (h['total'] as num?)?.toInt() ?? 0;
                    final leccionId =
                        (h['leccionId'] as String?) ?? '—';
                    final fecha = _formatFecha(h['fecha']);
                    final completada =
                        (h['completada'] as bool?) ?? false;
                    final color = precision >= 70
                        ? AppColors.secundario
                        : precision >= 40
                            ? AppColors.naranja1
                            : AppColors.rojo1;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      color.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  completada
                                      ? Icons.check_circle_outline
                                      : Icons.replay_rounded,
                                  size: 18,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      leccionId,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$aciertos/$total aciertos · $fecha',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      color.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$precision%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

// ── Sección: Consejo del día ──────────────────────────────────────────────────

class _SeccionConsejo extends StatelessWidget {
  final bool isDark;
  const _SeccionConsejo({required this.isDark});

  void _mostrarConsejosModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? AppColors.fondoOscuroSecundario
          : AppColors.fondoSecundario,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=800&h=400',
                  height: 200,
                  fit: BoxFit.cover,
                  cacheHeight: 400,
                  cacheWidth: 800,
                  errorBuilder: (_, _, _) =>
                      Container(height: 200, color: const Color(0xFF1A1A2E)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consejos Prácticos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ConsejoTile(
                      icon: Icons.record_voice_over,
                      iconColor: AppColors.secundario,
                      titulo: 'El sonido "TL"',
                      texto:
                          'Recuerda que "tl" es un solo chasquido lateral, no dos letras separadas. Intenta poner la lengua en el paladar y deja escapar el aire por los lados.',
                    ),
                    const SizedBox(height: 12),
                    _ConsejoTile(
                      icon: Icons.lightbulb_outline,
                      iconColor: AppColors.naranja1,
                      titulo: 'Práctica Diaria',
                      texto:
                          'Repasar 5 minutos al día es mucho más efectivo que estudiar 1 hora entera a la semana.',
                    ),
                    const SizedBox(height: 12),
                    _ConsejoTile(
                      icon: Icons.hearing,
                      iconColor: AppColors.azul1,
                      titulo: 'Acentuación',
                      texto:
                          'Presta atención a la acentuación al escuchar; casi todas las palabras son graves.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejo del día',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _mostrarConsejosModal(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Image.network(
                  'https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=800&h=400',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheHeight: 400,
                  cacheWidth: 800,
                  errorBuilder: (_, _, _) =>
                      Container(height: 200, color: const Color(0xFF1A1A2E)),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.25, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 18,
                  right: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secundario,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'GRAMÁTICA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "El sonido 'TL'",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Recuerda que 'tl' es un solo chasquido lateral...",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Text(
                            'Seguir leyendo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsejoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String titulo;
  final String texto;

  const _ConsejoTile({
    required this.icon,
    required this.iconColor,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
