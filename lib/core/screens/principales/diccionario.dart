import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

// ── Helpers de categoría / nivel ──────────────────────────────────────────────

IconData _iconoCategoria(String cat) {
  switch (cat.toLowerCase().trim()) {
    case 'naturaleza': return Icons.eco_outlined;
    case 'animales':   return Icons.pets;
    case 'espiritu':   return Icons.auto_awesome;
    case 'hogar':      return Icons.home_outlined;
    case 'cuerpo':     return Icons.accessibility_new_outlined;
    case 'comida':     return Icons.restaurant_outlined;
    case 'familia':    return Icons.people_outline;
    case 'numeros':    return Icons.pin_outlined;
    case 'colores':    return Icons.palette_outlined;
    default:           return Icons.book_outlined;
  }
}

Color _colorCategoria(String cat) {
  switch (cat.toLowerCase().trim()) {
    case 'naturaleza': return AppColors.azul1;
    case 'animales':   return AppColors.naranja1;
    case 'espiritu':   return AppColors.morado1;
    case 'hogar':      return AppColors.amarillo1;
    case 'cuerpo':     return AppColors.azulAqua;
    case 'comida':     return AppColors.secundario;
    case 'familia':    return AppColors.primario;
    default:           return AppColors.secundario;
  }
}

Color _colorNivel(String nivel) {
  switch (nivel) {
    case 'basico+':    return AppColors.azul1;
    case 'intermedio': return AppColors.naranja1;
    case 'avanzado':   return AppColors.rojo1;
    default:           return AppColors.secundario;
  }
}

String _normalizeTexto(String? texto) {
  final value = (texto ?? '').toLowerCase().trim();
  return value
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');
}

String? _normalizeNivel(String? nivel) {
  switch (_normalizeTexto(nivel)) {
    case 'basico': return 'basico';
    case 'basico+': return 'basico+';
    case 'intermedio': return 'intermedio';
    case 'avanzado': return 'avanzado';
    default: return null;
  }
}

List<String> _nivelesPermitidos(String? nivel) {
  final normalized = _normalizeNivel(nivel) ?? 'basico';
  return [normalized];
}

List<String> _nivelQueryVariants(String? nivel) {
  final normalized = _normalizeNivel(nivel) ?? 'basico';
  switch (normalized) {
    case 'basico+':
      return ['basico+', 'básico+', 'Basico+', 'Básico+'];
    case 'intermedio':
      return ['intermedio', 'Intermedio'];
    case 'avanzado':
      return ['avanzado', 'Avanzado'];
    default:
      return ['basico', 'básico', 'Basico', 'Básico'];
  }
}

// ── Modelos ───────────────────────────────────────────────────────────────────

class _Categoria {
  final String nombre;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;
  const _Categoria({
    required this.nombre,
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
  });
}

class _EntradaDiccionario {
  final String id;
  final String palabra;
  final String traduccion;
  final String variante;
  final String categoria;
  final String dificultad;
  final String imagenUrl;
  final IconData icono;

  const _EntradaDiccionario({
    required this.id,
    required this.palabra,
    required this.traduccion,
    this.variante = '',
    required this.categoria,
    this.dificultad = 'basico',
    this.imagenUrl = '',
    required this.icono,
  });

  factory _EntradaDiccionario.fromFirestore(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final cat = (d['categoria'] as String? ?? 'otras').trim();
    return _EntradaDiccionario(
      id:         doc.id,
      palabra:    (d['palabra_nahuatl']    as String? ?? '').trim(),
      traduccion: (d['traduccion_espanol'] as String? ?? '').trim(),
      variante:   (d['variante_nahuatl']   as String? ?? '').trim(),
      categoria:  cat,
      dificultad: (d['dificultad']         as String? ?? 'basico').trim(),
      imagenUrl:  (d['imagen_url']         as String? ?? '').trim(),
      icono:      _iconoCategoria(cat),
    );
  }
}

// ── Pantalla Principal ────────────────────────────────────────────────────────

class DiccionarioScreen extends StatefulWidget {
  const DiccionarioScreen({super.key});

  @override
  State<DiccionarioScreen> createState() => _DiccionarioScreenState();
}

class _DiccionarioScreenState extends State<DiccionarioScreen> {
  static const int _pageSize = 20;

  // Data
  final List<_EntradaDiccionario> _entradas = [];
  _EntradaDiccionario? _palabraDelDia;
  String? _nivelUsuario;

  // Pagination
  QueryDocumentSnapshot? _lastDoc;
  bool _isLoading    = true;
  bool _isLoadingMore = false;
  bool _hasMore      = true;

  // Filters
  String  _busqueda            = '';
  String? _categoriaFiltro;
  String? _nivelFiltro;       // selected difficulty chip (within allowed)

  // Selection (wide layout)
  _EntradaDiccionario? _seleccionada;

  // Scroll
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _inicializar();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 300) {
      _cargarMas();
    }
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _inicializar() async {
    await _leerNivelUsuario();
    await Future.wait([_cargarPrimeraPagina(), _cargarPalabraDelDia()]);
  }

  Future<void> _leerNivelUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      _nivelUsuario = _normalizeNivel(
          (doc.data() ?? {})['nivel_educativo'] as String?);
    } catch (_) {}
  }

  Future<void> _cargarPalabraDelDia() async {
    try {
      final nivel = _nivelUsuario ?? 'basico';
      final snap = await FirebaseFirestore.instance
          .collection('palabras')
          .where('dificultad', isEqualTo: nivel)
          .limit(60)
          .get();
      if (snap.docs.isEmpty) return;

      final now  = DateTime.now();
      final seed = now.year * 366 + now.month * 31 + now.day;
      final idx  = seed % snap.docs.length;
      if (mounted) {
        setState(() {
          _palabraDelDia =
              _EntradaDiccionario.fromFirestore(snap.docs[idx]);
        });
      }
    } catch (e) {
      debugPrint('_cargarPalabraDelDia error: $e');
    }
  }

  Future<void> _cargarPrimeraPagina() async {
    setState(() => _isLoading = true);
    try {
      final snap = await _buildQuery().limit(_pageSize).get();
      final nuevas = snap.docs
          .map((d) => _EntradaDiccionario.fromFirestore(d))
          .where((e) => e.palabra.isNotEmpty)
          .toList()
        ..sort((a, b) => a.palabra.compareTo(b.palabra));

      if (!mounted) return;
      setState(() {
        _entradas
          ..clear()
          ..addAll(nuevas);
        _lastDoc  = snap.docs.isNotEmpty ? snap.docs.last : null;
        _hasMore  = snap.docs.length == _pageSize;
        if (_entradas.isNotEmpty) _seleccionada = _entradas.first;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('_cargarPrimeraPagina error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarMas() async {
    if (_isLoadingMore || !_hasMore || _lastDoc == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final snap = await _buildQuery()
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize)
          .get();
      final nuevas = snap.docs
          .map((d) => _EntradaDiccionario.fromFirestore(d))
          .where((e) => e.palabra.isNotEmpty)
          .toList()
        ..sort((a, b) => a.palabra.compareTo(b.palabra));

      if (!mounted) return;
      setState(() {
        _entradas.addAll(nuevas);
        _entradas.sort((a, b) => a.palabra.compareTo(b.palabra));
        _lastDoc  = snap.docs.isNotEmpty ? snap.docs.last : _lastDoc;
        _hasMore  = snap.docs.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('_cargarMas error: $e');
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  /// Base Firestore query filtered by user's allowed levels.
  Query _buildQuery() {
    final nivel = _nivelUsuario ?? 'basico';
    return FirebaseFirestore.instance
        .collection('palabras')
        .where('dificultad', isEqualTo: nivel);
  }

  // ── Derived data ──────────────────────────────────────────────────────────

  List<_Categoria> get _categorias {
    final vistas   = <String>{};
    final resultado = <_Categoria>[];
    for (final e in _entradas) {
      if (!vistas.contains(e.categoria)) {
        vistas.add(e.categoria);
        final c = _colorCategoria(e.categoria);
        resultado.add(_Categoria(
          nombre:     e.categoria,
          icono:      _iconoCategoria(e.categoria),
          colorFondo: c.withValues(alpha: 0.2),
          colorIcono: c,
        ));
      }
    }
    return resultado;
  }

  /// Difficulty chips: only the levels the user is allowed to see.
  List<String> get _nivelesDisponibles => _nivelesPermitidos(_nivelUsuario);

  List<_EntradaDiccionario> get _entradasFiltradas {
    return _entradas.where((e) {
      final q = _busqueda.toLowerCase();
      final matchBusqueda = q.isEmpty ||
          e.palabra.toLowerCase().contains(q) ||
          e.traduccion.toLowerCase().contains(q) ||
          e.variante.toLowerCase().contains(q);
      final matchCat = _categoriaFiltro == null ||
          e.categoria == _categoriaFiltro;
      final matchNivel = _nivelFiltro == null ||
          e.dificultad == _nivelFiltro;
      return matchBusqueda && matchCat && matchNivel;
    }).toList();
  }

  bool get _hayFiltroActivo =>
      _busqueda.isNotEmpty ||
      _categoriaFiltro != null ||
      _nivelFiltro != null;

  void _abrirDetalle(_EntradaDiccionario e, bool isWide) {
    if (isWide) {
      setState(() => _seleccionada = e);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _DetallePantalla(entrada: e),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 1000;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.secundario),
        ),
      );
    }

    final listado = _Listado(
      isDark:              isDark,
      entradas:            _entradasFiltradas,
      categorias:          _categorias,
      nivelesDisponibles:  _nivelesDisponibles,
      palabraDelDia:       _palabraDelDia,
      busqueda:            _busqueda,
      categoriaFiltro:     _categoriaFiltro,
      nivelFiltro:         _nivelFiltro,
      hayFiltroActivo:     _hayFiltroActivo,
      isLoadingMore:       _isLoadingMore,
      hasMore:             _hasMore,
      scrollController:    _scroll,
      onBusquedaChanged: (v) {
        setState(() => _busqueda = v);
      },
      onCategoriaToggle: (cat) {
        setState(() => _categoriaFiltro =
            _categoriaFiltro == cat ? null : cat);
      },
      onNivelToggle: (n) {
        setState(() => _nivelFiltro = _nivelFiltro == n ? null : n);
      },
      onLimpiarFiltros: () {
        setState(() {
          _busqueda        = '';
          _categoriaFiltro = null;
          _nivelFiltro     = null;
        });
      },
      onEntradaTap: (e) => _abrirDetalle(e, isWide),
      onPalabraDelDiaTap:
          _palabraDelDia != null ? () => _abrirDetalle(_palabraDelDia!, isWide) : null,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      body: SafeArea(
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 760, child: listado),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: isDark
                        ? AppColors.extraOscuro120
                        : AppColors.extra120,
                  ),
                  Expanded(
                    child: _seleccionada == null
                        ? Center(
                            child: Text(
                              'Selecciona una palabra',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          )
                        : _DetalleView(
                            entrada: _seleccionada!, isDark: isDark),
                  ),
                ],
              )
            : listado,
      ),
    );
  }
}

// ── Listado ───────────────────────────────────────────────────────────────────

class _Listado extends StatelessWidget {
  final bool isDark;
  final List<_EntradaDiccionario> entradas;
  final List<_Categoria> categorias;
  final List<String> nivelesDisponibles;
  final _EntradaDiccionario? palabraDelDia;
  final String busqueda;
  final String? categoriaFiltro;
  final String? nivelFiltro;
  final bool hayFiltroActivo;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController scrollController;
  final ValueChanged<String> onBusquedaChanged;
  final ValueChanged<String> onCategoriaToggle;
  final ValueChanged<String> onNivelToggle;
  final VoidCallback onLimpiarFiltros;
  final ValueChanged<_EntradaDiccionario> onEntradaTap;
  final VoidCallback? onPalabraDelDiaTap;

  const _Listado({
    required this.isDark,
    required this.entradas,
    required this.categorias,
    required this.nivelesDisponibles,
    required this.palabraDelDia,
    required this.busqueda,
    required this.categoriaFiltro,
    required this.nivelFiltro,
    required this.hayFiltroActivo,
    required this.isLoadingMore,
    required this.hasMore,
    required this.scrollController,
    required this.onBusquedaChanged,
    required this.onCategoriaToggle,
    required this.onNivelToggle,
    required this.onLimpiarFiltros,
    required this.onEntradaTap,
    required this.onPalabraDelDiaTap,
  });

  @override
  Widget build(BuildContext context) {
    final sinFiltros = busqueda.isEmpty && categoriaFiltro == null && nivelFiltro == null;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscador
          TextField(
            onChanged: onBusquedaChanged,
            decoration: InputDecoration(
              hintText: 'Busca una palabra o traducción...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.fondoOscuroSecundario
                  : AppColors.fondoSecundario,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.textoClaro.withValues(alpha: 0.15)
                      : AppColors.textoSecundario.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide:
                    const BorderSide(color: AppColors.secundario),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Categorías
          if (categorias.isNotEmpty) ...[
            _SeccionHeader(
              titulo: 'Categorías',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorias
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _ChipCategoria(
                            categoria: c,
                            seleccionada: categoriaFiltro == c.nombre,
                            onTap: () => onCategoriaToggle(c.nombre),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Filtro por nivel
          if (nivelesDisponibles.isNotEmpty) ...[
            _SeccionHeader(titulo: 'Nivel', isDark: isDark),
            const SizedBox(height: 10),
            Row(
              children: nivelesDisponibles
                  .map((n) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ChipNivel(
                          nivel: n,
                          seleccionado: nivelFiltro == n,
                          onTap: () => onNivelToggle(n),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Limpiar filtros
          if (hayFiltroActivo) ...[
            GestureDetector(
              onTap: onLimpiarFiltros,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.rojo1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.rojo1.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close, size: 13, color: AppColors.rojo1),
                    const SizedBox(width: 5),
                    const Text(
                      'Limpiar filtros',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rojo1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Palabra del día
          if (sinFiltros && palabraDelDia != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SeccionHeader(titulo: 'Palabra del Día', isDark: isDark),
                Text(
                  'DESTACADO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.naranja1,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onPalabraDelDiaTap,
              child: _TarjetaPalabraDia(
                  entrada: palabraDelDia!, isDark: isDark),
            ),
            const SizedBox(height: 24),
          ],

          // Entradas header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SeccionHeader(
                titulo: hayFiltroActivo
                    ? 'Resultados (${entradas.length})'
                    : 'Palabras',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista
          if (entradas.isEmpty && !isLoadingMore)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Text(
                  'No se encontraron palabras.',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...entradas.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TarjetaEntrada(
                  entrada: e,
                  isDark: isDark,
                  onTap: () => onEntradaTap(e),
                ),
              ),
            ),

          // Loading more indicator
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.secundario, strokeWidth: 2),
              ),
            ),

          // End-of-list label
          if (!isLoadingMore && !hasMore && entradas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Has llegado al final del diccionario.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Pantalla detalle (móvil) ──────────────────────────────────────────────────

class _DetallePantalla extends StatelessWidget {
  final _EntradaDiccionario entrada;
  const _DetallePantalla({required this.entrada});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        centerTitle: true,
        title: Text(
          entrada.palabra,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
          child: _DetalleView(entrada: entrada, isDark: isDark)),
    );
  }
}

// ── Vista de detalle ──────────────────────────────────────────────────────────

class _DetalleView extends StatelessWidget {
  final _EntradaDiccionario entrada;
  final bool isDark;
  const _DetalleView({required this.entrada, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final catColor = _colorCategoria(entrada.categoria);
    final nivColor = _colorNivel(entrada.dificultad);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen
          if (entrada.imagenUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                entrada.imagenUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Palabra nahuatl
          Text(
            entrada.palabra,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.secundario,
              letterSpacing: -1,
            ),
          ),

          // Variante
          if (entrada.variante.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Variante: ${entrada.variante}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Traducción
          Text(
            entrada.traduccion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 14),

          // Badges categoría + nivel
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              _Badge(
                  label: entrada.categoria,
                  color: catColor,
                  icon: entrada.icono),
              _Badge(
                  label: entrada.dificultad,
                  color: nivColor,
                  icon: Icons.signal_cellular_alt_outlined),
            ],
          ),

          const SizedBox(height: 32),

          // Practicar
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.fondoOscuroSecundario
                    : AppColors.fondoSecundario,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 2,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome_outlined,
                      color: AppColors.secundario, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Practicar esta palabra',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Generar ejercicio rápido con IA',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Componentes ───────────────────────────────────────────────────────────────

class _SeccionHeader extends StatelessWidget {
  final String titulo;
  final bool isDark;
  const _SeccionHeader({required this.titulo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  final _Categoria categoria;
  final bool seleccionada;
  final VoidCallback onTap;
  const _ChipCategoria({
    required this.categoria,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: categoria.colorFondo,
              borderRadius: BorderRadius.circular(16),
              border: seleccionada
                  ? Border.all(color: categoria.colorIcono, width: 2)
                  : null,
            ),
            child: Center(
              child: Icon(categoria.icono,
                  color: categoria.colorIcono, size: 26),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 62,
            child: Text(
              categoria.nombre,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    seleccionada ? FontWeight.bold : FontWeight.w600,
                color: seleccionada
                    ? categoria.colorIcono
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipNivel extends StatelessWidget {
  final String nivel;
  final bool seleccionado;
  final VoidCallback onTap;
  const _ChipNivel({
    required this.nivel,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorNivel(nivel);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado
                ? color
                : color.withValues(alpha: 0.25),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Text(
          nivel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: seleccionado
                ? color
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

class _TarjetaPalabraDia extends StatelessWidget {
  final _EntradaDiccionario entrada;
  final bool isDark;
  const _TarjetaPalabraDia(
      {required this.entrada, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primario,
        image: entrada.imagenUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(entrada.imagenUrl),
                fit: BoxFit.cover,
                onError: (_, _) {},
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.82),
            ],
            stops: const [0.25, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secundario,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entrada.categoria.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              entrada.palabra,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              entrada.traduccion,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Ver detalle',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amarillo1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward,
                    size: 13, color: AppColors.amarillo1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaEntrada extends StatelessWidget {
  final _EntradaDiccionario entrada;
  final bool isDark;
  final VoidCallback onTap;
  const _TarjetaEntrada({
    required this.entrada,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = _colorCategoria(entrada.categoria);
    final nivColor = _colorNivel(entrada.dificultad);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.fondoOscuroSecundario
              : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail o ícono
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: entrada.imagenUrl.isNotEmpty
                  ? Image.network(
                      entrada.imagenUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _IconoCat(color: catColor, icono: entrada.icono),
                    )
                  : _IconoCat(color: catColor, icono: entrada.icono),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrada.palabra,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entrada.traduccion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: nivColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entrada.dificultad,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: nivColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconoCat extends StatelessWidget {
  final Color color;
  final IconData icono;
  const _IconoCat({required this.color, required this.icono});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        color: color.withValues(alpha: 0.12),
        child: Icon(icono, color: color, size: 20),
      );
}
