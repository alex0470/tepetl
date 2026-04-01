import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/inicio.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/bars/appbar_ejercicios.dart';
import 'package:tepetl/core/widgets/botones/boton_verificar_ejercicio.dart';
import 'package:tepetl/core/widgets/popups/respuesta_sheet.dart';
import 'package:tepetl/core/screens/errores/leccion_resumen.dart';
import 'package:tepetl/core/models/modelo_revision.dart';

/// Modelo de una opción de imagen.
class ImageOption {
  final String imageUrl;
  final String label;

  const ImageOption({required this.imageUrl, required this.label});
}

class PlantillaIdentificarImagen extends StatefulWidget {
  const PlantillaIdentificarImagen({super.key});

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
  int _hearts = 5;

  // ── Constantes del ejercicio ──────────────────────────────────────────────
  static const String _nahuatlWord = 'Calli';
  static const int _correctIndex = 0; // índice de la opción correcta
  static const String _hintText =
      '"Calli" en náhuatl significa "casa" o "hogar". Es una de las palabras más básicas del vocabulario cotidiano.';

  static const List<ImageOption> _options = [
    ImageOption(
      imageUrl:
          'https://images.unsplash.com/photo-1518780664697-55e3ad937233?w=400',
      label: 'Casa',
    ),
    ImageOption(
      imageUrl:
          'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=400',
      label: 'Agua',
    ),
    ImageOption(
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      label: 'Sol',
    ),
    ImageOption(
      imageUrl:
          'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=400',
      label: 'Árbol',
    ),
  ];

  // ── Lógica ────────────────────────────────────────────────────────────────
  void _verify() {
    if (_selectedIndex == null || _verified) return;

    final bool isCorrect = _selectedIndex == _correctIndex;

    setState(() {
      _verified = true;
      if (!isCorrect && _hearts > 0) _hearts--;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (_) => RespuestaSheet(
          isCorrect: isCorrect,
          explanation: isCorrect
              ? '"Calli" significa "casa" en náhuatl. Representa el hogar y el refugio en la cultura azteca.'
              : 'La respuesta correcta es "Casa". En náhuatl, "Calli" hace referencia al hogar o lugar de habitación.',
          correctAnswer: _options[_correctIndex].label,
          onContinue: () => Navigator.of(context).pop(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() {
          _verified = false;
          _selectedIndex = null;
        });
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => LeccionResumen(result: exampleLessonResult),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    });
  }

  // ── Colores de borde según estado ─────────────────────────────────────────
  Color _borderColor(int index) {
    if (!_verified) {
      return index == _selectedIndex
          ? AppColors.secundario
          : Colors.transparent;
    }
    if (index == _correctIndex) return AppColors.secundario;
    if (index == _selectedIndex) return Colors.red.shade400;
    return Colors.transparent;
  }

  double _borderWidth(int index) {
    if (!_verified && index == _selectedIndex) return 3;
    if (_verified && (index == _correctIndex || index == _selectedIndex)) {
      return 3;
    }
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
    final double progressWidth =
        isWide ? (sw * 1.0).clamp(600, 1700) : double.infinity;

    final bool hasSelection = _selectedIndex != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            AppbarEjercicios(
              title: 'IDENTIFICAR TEXTOS',
              hearts: _hearts,
              onClose: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const InicioScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),

            // ── Barra de progreso ─────────────────────────────────────────
            LessonProgressBar(
              lessonLabel: 'LECCIÓN 2',
              progress: 0.45,
              progressWidth: progressWidth,
            ),

            // ── Contenido scrollable ──────────────────────────────────────
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

                        // ── Título ──────────────────────────────────────
                        Text(
                          'Seleccione la imagen correcta para',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Palabra en náhuatl ──────────────────────────
                        Text(
                          "'$_nahuatlWord'",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
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

                        // ── Grid de imágenes ────────────────────────────
                        SizedBox(
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

                        if (isWide) ...[
                          SizedBox(height: sh * 0.08),

                          // ── Pista visible ───────────────────────────────
                          if (_hintVisible) ...[
                            _HintBox(text: _hintText),
                            const SizedBox(height: 16),
                          ],

                          // ── Botón pista ─────────────────────────────────
                          GestureDetector(
                            onTap: () =>
                                setState(() => _hintVisible = !_hintVisible),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: AppColors.secundario, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  _hintVisible
                                      ? 'Ocultar pista'
                                      : '¿Necesitas una pista?',
                                  style: const TextStyle(
                                    color: AppColors.secundario,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Botón verificar ─────────────────────────────
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
                    GestureDetector(
                      onTap: () => setState(() => _hintVisible = !_hintVisible),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: AppColors.secundario, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _hintVisible
                                ? 'Ocultar pista'
                                : '¿Necesitas una pista?',
                            style: const TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hintVisible) ...[
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
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
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
          borderRadius: BorderRadius.circular(
              borderWidth > 0 ? 13 : 16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Imagen ────────────────────────────────────────────────
              Image.network(
                option.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white54, size: 36),
                ),
              ),

              // ── Gradiente inferior ────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
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
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                        ),
                      ],
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