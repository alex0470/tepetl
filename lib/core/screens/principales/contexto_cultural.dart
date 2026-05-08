import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tepetl/core/models/articulo_cultura_model.dart';
import 'package:tepetl/core/services/cultura_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

// ── Pantalla principal ────────────────────────────────────────────────────────

class DescubrirScreen extends StatefulWidget {
  final bool esAdmin;
  const DescubrirScreen({super.key, this.esAdmin = false});

  @override
  State<DescubrirScreen> createState() => _DescubrirScreenState();
}

class _DescubrirScreenState extends State<DescubrirScreen> {
  final PageController _pageController = PageController();
  late final Stream<List<ArticuloCulturaModel>> _articulosStream;
  int _heroPage = 0;
  bool _puedoEditar = false;

  @override
  void initState() {
    super.initState();
    // El stream se crea UNA sola vez; recrearlo en build() haría que
    // StreamBuilder lo reiniciara en cada setState, destruyendo el PageView
    // y reseteando el carrusel a la página 0.
    _articulosStream = CulturaService.streamArticulos();
    _checkSistema();
  }

  Future<void> _checkSistema() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!mounted) return;
    setState(() => _puedoEditar = doc.data()?['sistema'] == true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _abrirArticulo(ArticuloCulturaModel articulo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ArticuloScreen(
          articulo: articulo,
          puedoEditar: _puedoEditar,
        ),
      ),
    );
  }

  void _abrirFormulario([ArticuloCulturaModel? articulo]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ArticuloFormScreen(articulo: articulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: widget.esAdmin
          ? FloatingActionButton(
              onPressed: () => _abrirFormulario(),
              backgroundColor: AppColors.secundario,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<List<ArticuloCulturaModel>>(
          stream: _articulosStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Error al cargar artículos',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }

            final articulos = snap.data ?? [];

            if (articulos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('Sin artículos por ahora',
                        style: TextStyle(fontSize: 15, color: Colors.grey[500])),
                    if (widget.esAdmin) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _abrirFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Crear primer artículo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secundario,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }

            final heroArticulos = articulos.take(3).toList();
            final safeHeroPage = _heroPage.clamp(0, heroArticulos.length - 1);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * (isWide ? 0.02 : 0.04),
                        vertical: sw * (isWide ? 0.03 : 0.04),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (isWide)
                            _WideLayout(
                              heroArticulos: heroArticulos,
                              todosArticulos: articulos,
                              pageController: _pageController,
                              heroPage: safeHeroPage,
                              onPageChanged: (i) => setState(() => _heroPage = i),
                              onTap: _abrirArticulo,
                              onEdit: _abrirFormulario,
                              isDark: isDark,
                              puedoEditar: _puedoEditar,
                            )
                          else
                            _MobileLayout(
                              heroArticulos: heroArticulos,
                              todosArticulos: articulos,
                              pageController: _pageController,
                              heroPage: safeHeroPage,
                              onPageChanged: (i) => setState(() => _heroPage = i),
                              onTap: _abrirArticulo,
                              onEdit: _abrirFormulario,
                              isDark: isDark,
                              puedoEditar: _puedoEditar,
                            ),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORMULARIO — Crear / Editar artículo (solo admin con sistema: true)
// ═══════════════════════════════════════════════════════════════════════════════

class _ArticuloFormScreen extends StatefulWidget {
  final ArticuloCulturaModel? articulo; // null = crear, non-null = editar
  const _ArticuloFormScreen({this.articulo});

  @override
  State<_ArticuloFormScreen> createState() => _ArticuloFormScreenState();
}

class _ArticuloFormScreenState extends State<_ArticuloFormScreen> {
  final _tituloCtrl      = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _contenidoCtrl   = TextEditingController();
  final _imagenUrlCtrl   = TextEditingController();

  // Imagen desde galería
  dynamic _imagenNueva;    // XFile cuando el usuario escoge una imagen
  Uint8List? _imagenBytes; // bytes para preview cross-platform

  bool _guardando = false;
  bool get _esEdicion => widget.articulo != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final a = widget.articulo!;
      _tituloCtrl.text      = a.titulo;
      _descripcionCtrl.text = a.descripcionCorta;
      _contenidoCtrl.text   = a.contenido;
      _imagenUrlCtrl.text   = a.imagenUrl;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _contenidoCtrl.dispose();
    _imagenUrlCtrl.dispose();
    super.dispose();
  }

  String get _autorActual {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Admin Tepetl';
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _imagenNueva  = xfile;
      _imagenBytes  = bytes;
      _imagenUrlCtrl.clear(); // la galería tiene prioridad; limpia la URL
    });
  }

  bool _validar() {
    if (_tituloCtrl.text.trim().isEmpty) {
      _mostrarError('El título es requerido');
      return false;
    }
    if (_descripcionCtrl.text.trim().isEmpty) {
      _mostrarError('La descripción corta es requerida');
      return false;
    }
    if (_contenidoCtrl.text.trim().isEmpty) {
      _mostrarError('El contenido no puede estar vacío');
      return false;
    }
    return true;
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _guardar() async {
    if (!_validar()) return;
    setState(() => _guardando = true);
    try {
      // Prioridad: imagen de galería > URL manual > URL existente
      String imagenUrl = _imagenUrlCtrl.text.trim();
      if (_imagenNueva != null) {
        final ruta = _esEdicion
            ? widget.articulo!.id
            : 'temp_${DateTime.now().millisecondsSinceEpoch}';
        imagenUrl = await CulturaService.subirImagenArticulo(_imagenNueva!, ruta);
      }

      if (_esEdicion) {
        await CulturaService.actualizarArticulo(widget.articulo!.id, {
          'titulo': _tituloCtrl.text.trim(),
          'descripcion_corta': _descripcionCtrl.text.trim(),
          'contenido': _contenidoCtrl.text.trim(),
          'imagen_url': imagenUrl,
        });
      } else {
        await CulturaService.crearArticulo(
          titulo: _tituloCtrl.text.trim(),
          descripcionCorta: _descripcionCtrl.text.trim(),
          contenido: _contenidoCtrl.text.trim(),
          imagenUrl: imagenUrl,
          autor: _autorActual,
        );
      }

      if (!mounted) return;
      Navigator.maybePop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_esEdicion ? 'Artículo actualizado' : 'Artículo publicado'),
      ));
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _esEdicion ? 'Editar artículo' : 'Nuevo artículo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? sw * 0.20 : 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Imagen: galería ───────────────────────────────────────
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secundario.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  color: isDark
                      ? AppColors.fondoOscuroSecundario
                      : AppColors.fondoSecundario,
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagenBytes != null
                    ? Stack(fit: StackFit.expand, children: [
                        Image.memory(_imagenBytes!, fit: BoxFit.cover),
                        _EditOverlay(),
                      ])
                    : _imagenUrlCtrl.text.trim().isNotEmpty
                        ? Stack(fit: StackFit.expand, children: [
                            Image.network(
                              _imagenUrlCtrl.text.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  _ImagePlaceholder(),
                            ),
                            _EditOverlay(),
                          ])
                        : _ImagePlaceholder(),
              ),
            ),

            // ── Imagen: URL manual ────────────────────────────────────
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Divider(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'O escribe una URL',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Expanded(child: Divider(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
                )),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _imagenUrlCtrl,
              keyboardType: TextInputType.url,
              onChanged: (val) {
                // Si escribe URL, descarta la imagen de galería
                if (val.trim().isNotEmpty) {
                  setState(() {
                    _imagenNueva = null;
                    _imagenBytes = null;
                  });
                } else {
                  setState(() {});
                }
              },
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'https://link-a-imagen.com/foto.jpg',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                prefixIcon: Icon(Icons.link_outlined, size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                suffixIcon: _imagenUrlCtrl.text.trim().isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(() => _imagenUrlCtrl.clear()),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secundario, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            // ── Título ────────────────────────────────────────────────
            _FormLabel(text: 'TÍTULO DEL ARTÍCULO'),
            const SizedBox(height: 8),
            _CampoTexto(
              controller: _tituloCtrl,
              hint: 'Ej. El simbolismo del Quetzal',
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // ── Descripción corta ─────────────────────────────────────
            _FormLabel(text: 'DESCRIPCIÓN CORTA'),
            const SizedBox(height: 8),
            _CampoTexto(
              controller: _descripcionCtrl,
              hint: 'Una breve introducción al artículo...',
              isDark: isDark,
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // ── Contenido ─────────────────────────────────────────────
            _FormLabel(text: 'CONTENIDO'),
            const SizedBox(height: 8),
            _BarraFormato(isDark: isDark),
            const SizedBox(height: 4),
            _CampoTexto(
              controller: _contenidoCtrl,
              hint: 'Escribe el artículo aquí...',
              isDark: isDark,
              maxLines: 12,
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(
                  'El tiempo de lectura se calcula automáticamente.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // ── Botón guardar ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_esEdicion ? Icons.save_outlined : Icons.send_outlined,
                        size: 18),
                label: Text(
                  _guardando
                      ? (_esEdicion ? 'Guardando...' : 'Publicando...')
                      : (_esEdicion ? 'Guardar cambios' : 'Publicar Artículo'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.secundario,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares del formulario ─────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_photo_alternate_outlined,
              color: AppColors.secundario, size: 28),
        ),
        const SizedBox(height: 10),
        const Text(
          'Toca para agregar imagen',
          style: TextStyle(
            color: AppColors.secundario,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG — desde galería',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.secundario.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _EditOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.secundario,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;

  const _CampoTexto({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secundario, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _BarraFormato extends StatelessWidget {
  final bool isDark;
  const _BarraFormato({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _FormatBtn(label: 'B', bold: true),
          _FormatBtn(label: 'I', italic: true),
          _FormatBtn(label: '≡'),
          _FormatBtn(label: '•'),
          const Spacer(),
          Icon(Icons.open_in_full, size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}

class _FormatBtn extends StatelessWidget {
  final String label;
  final bool bold;
  final bool italic;

  const _FormatBtn({required this.label, this.bold = false, this.italic = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {},
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

// ── Layout Ancho (Desktop / Tablet) ──────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final List<ArticuloCulturaModel> heroArticulos;
  final List<ArticuloCulturaModel> todosArticulos;
  final PageController pageController;
  final int heroPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ArticuloCulturaModel> onTap;
  final ValueChanged<ArticuloCulturaModel> onEdit;
  final bool isDark;
  final bool puedoEditar;

  const _WideLayout({
    required this.heroArticulos,
    required this.todosArticulos,
    required this.pageController,
    required this.heroPage,
    required this.onPageChanged,
    required this.onTap,
    required this.onEdit,
    required this.isDark,
    required this.puedoEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroCarousel(
                articulos: heroArticulos,
                controller: pageController,
                currentPage: heroPage,
                onPageChanged: onPageChanged,
                onTap: onTap,
                height: 450,
                isWide: true,
              ),
              _HeroPreviewCard(
                isDark: isDark,
                articulo: heroArticulos[heroPage],
                onTap: () => onTap(heroArticulos[heroPage]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(isDark: isDark, text: '¿Lo sabías?'),
              const SizedBox(height: 12),
              ...todosArticulos.map(
                (a) => _InfoCard(
                  isDark: isDark,
                  articulo: a,
                  onTap: () => onTap(a),
                  onEdit: puedoEditar ? () => onEdit(a) : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Layout Móvil ──────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final List<ArticuloCulturaModel> heroArticulos;
  final List<ArticuloCulturaModel> todosArticulos;
  final PageController pageController;
  final int heroPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ArticuloCulturaModel> onTap;
  final ValueChanged<ArticuloCulturaModel> onEdit;
  final bool isDark;
  final bool puedoEditar;

  const _MobileLayout({
    required this.heroArticulos,
    required this.todosArticulos,
    required this.pageController,
    required this.heroPage,
    required this.onPageChanged,
    required this.onTap,
    required this.onEdit,
    required this.isDark,
    required this.puedoEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCarousel(
          articulos: heroArticulos,
          controller: pageController,
          currentPage: heroPage,
          onPageChanged: onPageChanged,
          onTap: onTap,
          height: 260,
        ),
        const SizedBox(height: 20),
        _SectionTitle(isDark: isDark, text: '¿Lo sabías?'),
        const SizedBox(height: 12),
        ...todosArticulos.map(
          (a) => _InfoCard(
            isDark: isDark,
            articulo: a,
            onTap: () => onTap(a),
            onEdit: puedoEditar ? () => onEdit(a) : null,
          ),
        ),
      ],
    );
  }
}

// ── Helpers compartidos ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final bool isDark;
  final String text;
  const _SectionTitle({required this.isDark, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 10, color: AppColors.secundario),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
          ),
        ),
      ],
    );
  }
}

// ── _HeroPreviewCard ──────────────────────────────────────────────────────────

class _HeroPreviewCard extends StatelessWidget {
  final ArticuloCulturaModel articulo;
  final VoidCallback onTap;
  final bool isDark;

  const _HeroPreviewCard({
    required this.articulo,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
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
          Text(
            'Avance del artículo',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            articulo.titulo,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            articulo.descripcionCorta,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            articulo.contenido,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Ver más detalles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Carousel ─────────────────────────────────────────────────────────────

class _HeroCarousel extends StatelessWidget {
  final List<ArticuloCulturaModel> articulos;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ArticuloCulturaModel> onTap;
  final double height;
  final bool isWide;

  const _HeroCarousel({
    required this.articulos,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTap,
    this.height = 260,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: articulos.length,
              physics: const PageScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) => _HeroSlide(
                articulo: articulos[i],
                onTap: () => onTap(articulos[i]),
                isWide: isWide,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(
              icon: Icons.chevron_left,
              onTap: currentPage > 0
                  ? () => controller.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut)
                  : null,
            ),
            const SizedBox(width: 8),
            ...List.generate(
              articulos.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == currentPage
                      ? AppColors.secundario
                      : AppColors.secundario.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ArrowButton(
              icon: Icons.chevron_right,
              onTap: currentPage < articulos.length - 1
                  ? () => controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.secundario),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final ArticuloCulturaModel articulo;
  final VoidCallback onTap;
  final bool isWide;

  const _HeroSlide({
    required this.articulo,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            articulo.imagenUrl.isNotEmpty
                ? Image.network(
                    articulo.imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Container(color: Colors.grey.shade800),
                  )
                : Container(
                    color: AppColors.primario.withValues(alpha: 0.8),
                    child: const Icon(Icons.article_outlined,
                        size: 64, color: Colors.white54),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secundario.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      articulo.autor.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isWide) ...[
                    Text(
                      articulo.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      articulo.descripcionCorta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textoSecundario20, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: AppColors.textoSecundario20, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        articulo.duracion,
                        style: const TextStyle(
                            color: AppColors.textoSecundario20, fontSize: 13),
                      ),
                      if (!isWide) ...[
                        const Spacer(),
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secundario,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            minimumSize: const Size(120, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Leer artículo',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final ArticuloCulturaModel articulo;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _InfoCard({
    required this.isDark,
    required this.articulo,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(18),
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        articulo.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textoClaro
                              : AppColors.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        articulo.descripcionCorta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textoClaro
                              : AppColors.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Aprende más...',
                        style: TextStyle(
                          color: AppColors.secundario,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: articulo.imagenUrl.isNotEmpty
                      ? Image.network(
                          articulo.imagenUrl,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _FallbackThumb(),
                        )
                      : _FallbackThumb(),
                ),
              ],
            ),
            // Botón editar — solo visible cuando puedoEditar
            if (onEdit != null) ...[
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onEdit,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 13,
                        color: AppColors.secundario.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      'Editar artículo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secundario.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FallbackThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      color: AppColors.primario.withValues(alpha: 0.15),
      child: const Icon(Icons.article_outlined, color: AppColors.primario, size: 30),
    );
  }
}

// ── Pantalla de artículo ──────────────────────────────────────────────────────

class _ArticuloScreen extends StatelessWidget {
  final ArticuloCulturaModel articulo;
  final bool puedoEditar;

  const _ArticuloScreen({
    required this.articulo,
    this.puedoEditar = false,
  });

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 700;
    final fechaStr = _formatFecha(articulo.fechaPublicacion);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  BotonAtras(onPressed: () => Navigator.maybePop(context)),
                  Expanded(
                    child: Text(
                      articulo.autor.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secundario,
                      ),
                    ),
                  ),
                  if (puedoEditar)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.secundario, size: 20),
                      tooltip: 'Editar artículo',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              _ArticuloFormScreen(articulo: articulo),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: isWide
                  ? _ArticuloWide(
                      articulo: articulo,
                      isDark: isDark,
                      fechaStr: fechaStr,
                    )
                  : _ArticuloNarrow(
                      articulo: articulo,
                      isDark: isDark,
                      fechaStr: fechaStr,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Artículo: layout ancho ────────────────────────────────────────────────────

class _ArticuloWide extends StatelessWidget {
  final ArticuloCulturaModel articulo;
  final bool isDark;
  final String fechaStr;

  const _ArticuloWide({
    required this.articulo,
    required this.isDark,
    required this.fechaStr,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: articulo.imagenUrl.isNotEmpty
                      ? Image.network(
                          articulo.imagenUrl,
                          height: 340,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              Container(height: 340, color: Colors.grey.shade300),
                        )
                      : Container(
                          height: 340,
                          color: AppColors.primario.withValues(alpha: 0.15),
                          child: const Icon(Icons.article_outlined,
                              size: 80, color: AppColors.primario),
                        ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secundario.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        articulo.autor,
                        style: const TextStyle(
                          color: AppColors.secundario,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 15,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.85)),
                    const SizedBox(width: 4),
                    Text(
                      articulo.duracion,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.85)),
                    ),
                  ],
                ),
                if (fechaStr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    fechaStr,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  articulo.titulo,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  articulo.descripcionCorta,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1)),
                const SizedBox(height: 20),
                Text(
                  articulo.contenido,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.9,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Artículo: layout estrecho (móvil) ────────────────────────────────────────

class _ArticuloNarrow extends StatelessWidget {
  final ArticuloCulturaModel articulo;
  final bool isDark;
  final String fechaStr;

  const _ArticuloNarrow({
    required this.articulo,
    required this.isDark,
    required this.fechaStr,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: articulo.imagenUrl.isNotEmpty
                ? Image.network(
                    articulo.imagenUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Container(height: 220, color: Colors.grey.shade300),
                  )
                : Container(
                    height: 220,
                    color: AppColors.primario.withValues(alpha: 0.15),
                    child: const Icon(Icons.article_outlined,
                        size: 70, color: AppColors.primario),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  articulo.autor,
                  style: const TextStyle(
                    color: AppColors.secundario,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(articulo.duracion,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (fechaStr.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fechaStr,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            articulo.titulo,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            articulo.descripcionCorta,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            articulo.contenido,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
