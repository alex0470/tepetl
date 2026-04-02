import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/imagenes_ejercicio.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/bars/appbar_ejercicios.dart';
import 'package:tepetl/core/widgets/botones/boton_verificar_ejercicio.dart';
import 'package:tepetl/core/widgets/popups/respuesta_sheet.dart';

class PlantillaEscribir extends StatefulWidget {
  const PlantillaEscribir({super.key});

  @override
  State<PlantillaEscribir> createState() => _PlantillaEscribirState();
}

class _PlantillaEscribirState extends State<PlantillaEscribir> {
  // ── Estado ────────────────────────────────────────────────────────────────
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hintVisible = false;
  bool _verified = false;
  int _hearts = 5;

  // ── Constantes del ejercicio ──────────────────────────────────────────────
  static const String _nahuatlWord = 'Tlazocamati';
  static const String _correctAnswer = 'Gracias';
  static const String _imageAsset = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE7yMfNNvo3tR8ceeaG0-GbZi0YWo4kjRTcg&s'; // imagen del ejercicio
  static const String _imageCategory = 'Cultura Azteca';
  static const String _imageDescription = 'Uso ceremonial';
  static const String _hintText =
      '"Tlazocamati" es una expresión de gratitud en náhuatl clásico. Se usa para agradecer algo a alguien.';

  // ── Lógica ────────────────────────────────────────────────────────────────

  /// Normaliza texto: sin espacios extra, sin distinción mayúsculas/minúsculas
  /// y sin acentos para comparación flexible.
  String _normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  void _verify() {
    if (_controller.text.trim().isEmpty || _verified) return;

    final bool isCorrect =
        _normalize(_controller.text) == _normalize(_correctAnswer);

    setState(() {
      _verified = true;
      if (!isCorrect && _hearts > 0) _hearts--;
    });

    _focusNode.unfocus();

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
              ? '"Tlazocamati" significa "gracias" en náhuatl clásico. Es una de las expresiones más comunes de cortesía en esta lengua.'
              : 'La traducción correcta de "Tlazocamati" es "Gracias". Proviene del verbo "tlazotla" que expresa valorar o apreciar.',
          correctAnswer: _correctAnswer,
          onContinue: () => Navigator.of(context).pop(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() {
          _verified = false;
        });
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const PlantillaIdentificarImagen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isWide = sw > 1000;

    final double contentWidth =
        isWide ? (sw * 0.75).clamp(600, 900) : double.infinity;
    final double progressWidth =
        isWide ? (sw * 1.0).clamp(600, 1700) : double.infinity;

    final bool hasInput = _controller.text.trim().isNotEmpty;

    return Scaffold(
      // Evita que el teclado empuje todo el layout
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            AppbarEjercicios(
              title: 'EXPRESIÓN ESCRITA',
              hearts: _hearts,
              onClose: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const MainScreen(),
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
              child: GestureDetector(
                onTap: () => _focusNode.unfocus(),
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: sh * 0.03),

                            // ── Título ──────────────────────────────────────
                            Center(
                              child: Text(
                                'Lee y escribe',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),

                            SizedBox(height: sh * 0.025),

                            // ── Tarjeta de imagen ───────────────────────────
                            _ImageCard(
                              imageAsset: _imageAsset,
                              category: _imageCategory,
                              description: _imageDescription,
                            ),

                            SizedBox(height: sh * 0.025),

                            // ── Palabra en náhuatl ──────────────────────────
                            Center(
                              child: Text(
                                _nahuatlWord,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),

                            SizedBox(height: sh * 0.03),

                            // ── Label campo ─────────────────────────────────
                            Text(
                              'Tu traducción',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ── Campo de texto ──────────────────────────────
                            _TranslationField(
                              controller: _controller,
                              focusNode: _focusNode,
                              enabled: !_verified,
                              onChanged: (_) => setState(() {}),
                            ),

                            SizedBox(height: sh * 0.035),

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

                            SizedBox(height: sh * 0.03),

                            // ── Botón verificar ─────────────────────────────
                            BotonVerificarEjercicio(
                              enabled: hasInput && !_verified,
                              onPressed: _verify,
                            ),

                            SizedBox(height: sh * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de imagen ─────────────────────────────────────────────────────────
class _ImageCard extends StatelessWidget {
  final String imageAsset;
  final String category;
  final String description;

  const _ImageCard({
    required this.imageAsset,
    required this.category,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Imagen ──────────────────────────────────────────────────
            Image.network(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.image_not_supported,
                    color: Colors.white54, size: 48),
              ),
            ),

            // ── Gradiente inferior ───────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge de categoría
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secundario.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Campo de traducción ───────────────────────────────────────────────────────
class _TranslationField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _TranslationField({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldBg = isDark
        ? AppColors.fondoOscuroSecundario
        : AppColors.fondoSecundario;

    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secundario.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        onChanged: onChanged,
        minLines: 1,
        maxLines: 3,
        textAlignVertical: TextAlignVertical.center,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Escribe en español',
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          // Ícono de micrófono decorativo (igual a la imagen)
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