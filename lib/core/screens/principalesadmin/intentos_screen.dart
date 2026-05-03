import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class IntentosScreen extends StatefulWidget {
  final String uid;
  final String nombreUsuario;
  final String cursoId;
  final String cursoTitulo;

  const IntentosScreen({
    super.key,
    required this.uid,
    required this.nombreUsuario,
    required this.cursoId,
    required this.cursoTitulo,
  });

  @override
  State<IntentosScreen> createState() => _IntentosScreenState();
}

class _IntentosScreenState extends State<IntentosScreen> {
  List<Map<String, dynamic>> _intentos = [];
  Map<String, String> _titulosLecciones = {};
  bool _isLoading = true;
  String? _filtroLeccion;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_cargarTitulos(), _cargarHistorial()]);
    } catch (e) {
      debugPrint('Error cargando intentos: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _cargarTitulos() async {
    final modulosSnap = await FirebaseFirestore.instance
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('modulos')
        .get();

    final titulos = <String, String>{};
    for (final mDoc in modulosSnap.docs) {
      final leccionesSnap =
          await mDoc.reference.collection('lecciones').get();
      for (final lDoc in leccionesSnap.docs) {
        titulos[lDoc.id] = lDoc.data()['titulo'] as String? ?? lDoc.id;
      }
    }
    _titulosLecciones = titulos;
  }

  Future<void> _cargarHistorial() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('progreso_cursos')
        .doc(widget.cursoId)
        .get();

    final data = doc.data();
    if (data == null) return;

    // Los datos viven en el mapa `lecciones` dentro del documento principal
    final leccionesMap = data['lecciones'] as Map<String, dynamic>? ?? {};

    final lista = leccionesMap.entries.map((entry) {
      final leccionId = entry.key;
      final d = entry.value as Map<String, dynamic>;
      return {
        'leccionId': leccionId,
        'aciertos': (d['aciertos'] as num?)?.toInt() ?? 0,
        'total': (d['total'] as num?)?.toInt() ?? 0,
        'precision': (d['precision'] as num?)?.toInt() ?? 0,
        'completada': d['completada'] as bool? ?? false,
        'fecha': d['fecha'] as Timestamp?,
      };
    }).toList();

    // Ordenar por fecha descendente (más recientes primero)
    lista.sort((a, b) {
      final ta = a['fecha'] as Timestamp?;
      final tb = b['fecha'] as Timestamp?;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });

    _intentos = lista;
  }

  List<Map<String, dynamic>> get _filtrados => _filtroLeccion == null
      ? _intentos
      : _intentos
          .where((i) => i['leccionId'] == _filtroLeccion)
          .toList();

  List<String> get _leccionesUnicas => _intentos
      .map((i) => i['leccionId'] as String)
      .toSet()
      .toList();

  String _titulo(String leccionId) =>
      _titulosLecciones[leccionId] ?? leccionId;

  String _formatFecha(Timestamp? ts) {
    if (ts == null) return '—';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.fondoOscuroSecundario : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : AppColors.fondoSecundario,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.fondoOscuroSecundario : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'INTENTOS DE EJERCICIOS',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              widget.nombreUsuario,
              style: const TextStyle(
                  fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.secundario))
          : Column(
              children: [
                // ── Encabezado de curso ─────────────────────────────────
                Container(
                  color: isDark
                      ? AppColors.fondoOscuroSecundario
                      : Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secundario
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.book_outlined,
                                color: AppColors.secundario, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.cursoTitulo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          _StatBadge(
                              label: '${_intentos.length} intentos',
                              color: AppColors.azul1),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Filtro por lección ─────────────────────────
                      if (_leccionesUnicas.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FiltroChip(
                                label: 'Todas',
                                selected: _filtroLeccion == null,
                                onTap: () => setState(
                                    () => _filtroLeccion = null),
                              ),
                              const SizedBox(width: 8),
                              ..._leccionesUnicas.map((lid) => Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8),
                                    child: _FiltroChip(
                                      label: _titulo(lid),
                                      selected: _filtroLeccion == lid,
                                      onTap: () => setState(
                                          () => _filtroLeccion = lid),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Lista de intentos ───────────────────────────────────
                Expanded(
                  child: _filtrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history,
                                  size: 48,
                                  color: AppColors.textoSecundario40),
                              const SizedBox(height: 12),
                              Text(
                                _intentos.isEmpty
                                    ? 'El usuario aún no ha completado\nninguna lección en este curso.'
                                    : 'No hay intentos para esta lección.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textoSecundario40,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final intento = _filtrados[i];
                            return _IntentoCard(
                              leccionTitulo:
                                  _titulo(intento['leccionId'] as String),
                              aciertos: intento['aciertos'] as int,
                              total: intento['total'] as int,
                              precision: intento['precision'] as int,
                              completada: intento['completada'] as bool,
                              fecha: _formatFecha(
                                  intento['fecha'] as Timestamp?),
                              isDark: isDark,
                              cardColor: cardColor,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ── Card de un intento ────────────────────────────────────────────────────────

class _IntentoCard extends StatelessWidget {
  final String leccionTitulo;
  final int aciertos;
  final int total;
  final int precision;
  final bool completada;
  final String fecha;
  final bool isDark;
  final Color cardColor;

  const _IntentoCard({
    required this.leccionTitulo,
    required this.aciertos,
    required this.total,
    required this.precision,
    required this.completada,
    required this.fecha,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = completada ? AppColors.secundario : AppColors.rojo1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
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
          // ── Encabezado ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  leccionTitulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  completada ? 'APROBADO' : 'NO APROBADO',
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Datos en fila ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DatoIntento(
                  etiqueta: 'Respuesta usuario',
                  valor: '$aciertos / $total correctas',
                  icono: Icons.person_outline,
                  color: AppColors.azul1,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DatoIntento(
                  etiqueta: 'Umbral para aprobar',
                  valor: '≥ 70% (${(total * 0.7).ceil()} / $total)',
                  icono: Icons.check_circle_outline,
                  color: AppColors.secundario,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Barra de precisión + fecha ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Precisión',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textoSecundario40)),
                        Text('$precision%',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: resultColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: precision / 100,
                        backgroundColor: isDark
                            ? AppColors.extraOscuro120
                            : AppColors.extra120,
                        color: resultColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Fecha ───────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 13, color: AppColors.textoSecundario40),
              const SizedBox(width: 5),
              Text(
                fecha,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoSecundario40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dato individual ──────────────────────────────────────────────────────────

class _DatoIntento extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;
  final Color color;
  final bool isDark;

  const _DatoIntento({
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 12, color: color),
              const SizedBox(width: 4),
              Text(etiqueta,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FiltroChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secundario
              : AppColors.secundario.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                selected ? Colors.white : AppColors.secundario,
          ),
        ),
      ),
    );
  }
}
