import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_verificar_ejercicio.dart';
import 'package:tepetl/core/widgets/popups/respuesta_sheet.dart';
import 'package:tepetl/core/models/modelo_ejercicio.dart';

/// Par label + URL de imagen que se construye consultando Firestore.
class ImageOption {
  final String label;
  final String? imageUrl; // null mientras carga o si no se encontró

  const ImageOption({required this.label, this.imageUrl});
}

class PlantillaIdentificarImagen extends StatefulWidget {
  final EjercicioModel ejercicio;
  final Function(bool) onCompletado;

  const PlantillaIdentificarImagen({
    super.key,
    required this.ejercicio,
    required this.onCompletado,
  });

  @override
  State<PlantillaIdentificarImagen> createState() =>
      _PlantillaIdentificarImagenState();
}

class _PlantillaIdentificarImagenState
    extends State<PlantillaIdentificarImagen> {
  // ── Estado ────────────────────────────────────────────────────────────────
  int? _selectedIndex;
  bool _verified = false;
  bool _hintVisible = false;
  bool _loadingImages = true;

  // ── Datos dinámicos ───────────────────────────────────────────────────────
  late String _palabraNahuatl; // extraída del contenido entre comillas simples
  late String _correctAnswer;
  late String _hintText;
  late int _correctIndex;
  List<ImageOption> _options = [];

  @override
  @override
  void initState() {
    super.initState();
    _correctAnswer = widget.ejercicio.respuesta;
    _hintText = widget.ejercicio.pista;

    // Extraer la palabra en náhuatl del contenido
    final match = RegExp(r"'([^']+)'").firstMatch(widget.ejercicio.contenido);
    _palabraNahuatl = match != null ? match.group(1)! : widget.ejercicio.contenido;

    // 1. Copiamos las opciones para no modificar la lista original
    List<String> opcionesMezcladas = List.from(widget.ejercicio.opciones);

    // 2. ¡LA MAGIA! Mezclamos la lista al azar
    opcionesMezcladas.shuffle();

    // 3. Inicializamos las opciones de imagen con la lista ya mezclada
    _options = opcionesMezcladas
        .map((label) => ImageOption(label: label))
        .toList();

    // 4. Calculamos en qué índice quedó la respuesta correcta tras mezclar
    _correctIndex = opcionesMezcladas.indexOf(_correctAnswer);

    _cargarImagenes();
  }

  Future<void> _cargarImagenes() async {
    final db = FirebaseFirestore.instance;
    
    // Usamos _options porque ya están mezcladas. 
    // Si usamos widget.ejercicio.opciones, ¡desharíamos la mezcla al terminar de cargar!
    final futures = _options.map((opcionActual) async {
      try {
        final snap = await db
            .collection('vocabulario')
            .where('traduccion', isEqualTo: opcionActual.label)
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final url = snap.docs.first.data()['imagen_url'] as String?;
          return ImageOption(label: opcionActual.label, imageUrl: url);
        }
      } catch (_) {}
      
      // Si no encontramos nada, devolvemos sin imagen
      return ImageOption(label: opcionActual.label);
    });

    final results = await Future.wait(futures);

    if (!mounted) return;
    setState(() {
      // Guardamos los resultados que ya traen las imágenes y respetan el orden mezclado
      _options = results;
      _loadingImages = false;
    });
  }

  // ── Lógica de verificación ─────────────────────────────────────────────────
  void _verify() {
    if (_selectedIndex == null || _verified) return;

    // Guard: si _correctIndex es -1 (respuesta no encontrada en opciones),
    // comparamos por label directamente
    final bool isCorrect = _correctIndex != -1
        ? _selectedIndex == _correctIndex
        : _options[_selectedIndex!].label == _correctAnswer;

    setState(() {
      _verified = true;
    });

    final String explanation = isCorrect
        ? 'Excelente! Has seleccionado la imagen correcta de "$_correctAnswer".'
        : 'La imagen correcta era la de "$_correctAnswer".\n${widget.ejercicio.pista}';

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => RespuestaSheet(
          isCorrect: isCorrect,
          explanation: explanation,
          correctAnswer: _correctAnswer,
          onContinue: () => Navigator.of(context).pop(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() {
          _verified = false;
          _selectedIndex = null;
        });
        widget.onCompletado(isCorrect);
      });
    });
  }

  // ── Colores de borde según estado ─────────────────────────────────────────
  Color _borderColor(int index) {
    if (!_verified) {
      return index == _selectedIndex ? AppColors.secundario : Colors.transparent;
    }
    if (index == _correctIndex) return AppColors.secundario;
    if (index == _selectedIndex) return Colors.red.shade400;
    return Colors.transparent;
  }

  double _borderWidth(int index) {
    if (!_verified && index == _selectedIndex) return 3;
    if (_verified && (index == _correctIndex || index == _selectedIndex)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isWide = sw > 600;
    final double contentWidth =
        isWide ? (sw * 0.75).clamp(600, 900) : double.infinity;
    final double gridWidth =
        isWide ? (sw * 1).clamp(520, 620) : double.infinity;
    final bool hasSelection = _selectedIndex != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: sh * 0.03),

                        // ── Instrucción ──────────────────────────────────
                        Text(
                          'Selecciona la imagen correcta para',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Palabra en náhuatl ────────────────────────────
                        Text(
                          "'$_palabraNahuatl'",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secundario,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Toca la tarjeta que coincide con la palabra.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),

                        SizedBox(height: sh * 0.025),

                        // ── Grid de imágenes ──────────────────────────────
                        _loadingImages
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: CircularProgressIndicator(),
                              )
                            : SizedBox(
                                width: gridWidth,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _options.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: isWide ? 1.1 : 1.05,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _ImageOptionCard(
                                      option: _options[index],
                                      isSelected: _selectedIndex == index,
                                      borderColor: _borderColor(index),
                                      borderWidth: _borderWidth(index),
                                      onTap: _verified
                                          ? null
                                          : () => setState(
                                              () => _selectedIndex = index),
                                    );
                                  },
                                ),
                              ),

                        // ── Sección pista + botón (solo en wide) ──────────
                        if (isWide) ...[
                          SizedBox(height: sh * 0.04),
                          if (_hintVisible && _hintText.isNotEmpty) ...[
                            _HintBox(text: _hintText),
                            const SizedBox(height: 16),
                          ],
                          if (_hintText.isNotEmpty)
                            _PistaToggle(
                              visible: _hintVisible,
                              onTap: () =>
                                  setState(() => _hintVisible = !_hintVisible),
                            ),
                          const SizedBox(height: 18),
                          BotonVerificarEjercicio(
                            enabled: hasSelection && !_verified,
                            onPressed: _verify,
                          ),
                          SizedBox(height: sh * 0.02),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom bar móvil ──────────────────────────────────────────────────
      bottomNavigationBar: !isWide
          ? SafeArea(
              top: false,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.fromLTRB(sw * 0.05, 12, sw * 0.05, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hintText.isNotEmpty)
                      _PistaToggle(
                        visible: _hintVisible,
                        onTap: () =>
                            setState(() => _hintVisible = !_hintVisible),
                      ),
                    if (_hintVisible && _hintText.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _HintBox(text: _hintText),
                    ],
                    const SizedBox(height: 12),
                    BotonVerificarEjercicio(
                      enabled: hasSelection && !_verified,
                      onPressed: _verify,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// ── Botón de pista reutilizable ───────────────────────────────────────────────
class _PistaToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _PistaToggle({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.secundario, size: 18),
          const SizedBox(width: 6),
          Text(
            visible ? 'Ocultar pista' : '¿Necesitas una pista?',
            style: const TextStyle(
              color: AppColors.secundario,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de opción de imagen ───────────────────────────────────────────────
class _ImageOptionCard extends StatelessWidget {
  final ImageOption option;
  final bool isSelected;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const _ImageOptionCard({
    required this.option,
    required this.isSelected,
    required this.borderColor,
    required this.borderWidth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secundario.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderWidth > 0 ? 13 : 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Imagen o placeholder ──────────────────────────────────
              option.imageUrl != null && option.imageUrl!.isNotEmpty
                  ? Image.network(
                      option.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              color: Colors.grey.shade900,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                      errorBuilder: (_, _, _) => _Placeholder(label: option.label),
                    )
                  : _Placeholder(label: option.label),

              // ── Gradiente + label ─────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    option.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder cuando no hay imagen disponible.
class _Placeholder extends StatelessWidget {
  final String label;

  const _Placeholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secundario.withValues(alpha: 0.15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined,
                color: AppColors.secundario.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Caja de pista ─────────────────────────────────────────────────────────────
class _HintBox extends StatelessWidget {
  final String text;

  const _HintBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amarillo1.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.amarillo1, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: AppColors.amarillo1, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.amarillo1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}