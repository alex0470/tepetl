import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/inicio.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/bars/appbar_ejercicios.dart';
import 'package:tepetl/core/widgets/botones/boton_verificar_ejercicio.dart';
import 'package:tepetl/core/widgets/inputs/respuestas_chips.dart';
import 'package:tepetl/core/screens/plantillas_ejercicios/escribir.dart';
import 'package:tepetl/core/widgets/popups/respuesta_sheet.dart';

class PlantillaCompletar extends StatefulWidget {
  const PlantillaCompletar({super.key});

  @override
  State<PlantillaCompletar> createState() => _PlantillaCompletarState();
}

class _PlantillaCompletarState extends State<PlantillaCompletar> {
  int _selectedIndex = -1;
  bool _hintVisible = false;
  bool _verified = false;
  int _hearts = 5;

  // Constantes del ejercicio
  static const String _correctAnswer = 'nitlahtoa';
  static const int _correctIndex = 1;
  static const String _hintText =
      'La palabra que buscas significa "hablar". En náhuatl, los verbos en primera persona comienzan con "ni-".';

  static const List<String> _options = [
    'niquihtoa',
    'nitlahtoa',
    'nimitztlazohtla',
  ];

  static const List<String> _explanations = [
    '"Niquihtoa" significa "yo digo" o "yo declaro", no "yo hablo". Recuerda que buscamos el verbo para hablar un idioma.',
    '"Nitlahtoa" significa "yo hablo". Es el verbo "tlahtoa" conjugado en primera persona con el prefijo "ni-", propio del náhuatl clásico.',
    '"Nimitztlazohtla" significa "te amo" o "te quiero". Recuerda que buscamos el verbo para hablar un idioma.',
  ];

  void _verify() {
    if (_selectedIndex == -1 || _verified) return;

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
        builder: (ctx) => RespuestaSheet(
          isCorrect: isCorrect,
          explanation: _explanations[_selectedIndex],
          correctAnswer: _correctAnswer,
          onContinue: () => Navigator.of(ctx).pop(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() {
          _verified = false;
          _selectedIndex = -1;
        });
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) => const PlantillaEscribir(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isWide = sw > 1000;

    final double contentWidth = isWide ? sw * 0.96 : double.infinity;
    final double progressWidth =
        isWide ? (sw * 1.0).clamp(600, 1700) : double.infinity;

    final String? selectedWord =
        _selectedIndex != -1 ? _options[_selectedIndex] : null;
    final double iconSize = isWide ? 120 : sw * 0.2;
    final double titleFontSize = isWide ? 18 : 16;
    final double instructionSpacing = isWide ? 24 : 16;
    final double hintTextSize = isWide ? 15 : 13;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──────────────────────────────────────────────────
            AppbarEjercicios(
              title: 'EXPRESIÓN ESCRITA',
              hearts: _hearts,
              onClose: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (ctx, a1, a2) => const InicioScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),

            // ── Barra de progreso ────────────────────────────────────────
            LessonProgressBar(
              lessonLabel: 'LECCIÓN 2',
              progress: 0.45,
              progressWidth: progressWidth,
            ),

            // ── Contenido ────────────────────────────────────────────────
            Expanded(
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: isWide
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Panel izquierdo
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 32,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: iconSize,
                                      height: iconSize,
                                      decoration: BoxDecoration(
                                        color: AppColors.secundario
                                            .withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.record_voice_over_outlined,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                    SizedBox(height: sh * 0.04),
                                    _buildPhrase(
                                      context,
                                      isWide,
                                      selectedWord,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 32,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SELECCIONA LA PALABRA QUE FALTA',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(height: instructionSpacing),
                                    OptionsGrid(
                                      options: _options,
                                      selectedIndex: _selectedIndex,
                                      correctIndex: _correctIndex,
                                      verified: _verified,
                                      onSelect: (i) =>
                                          setState(() => _selectedIndex = i),
                                    ),
                                    SizedBox(height: instructionSpacing),
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _hintVisible = !_hintVisible,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            color: AppColors.secundario,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _hintVisible
                                                ? 'Ocultar pista'
                                                : '¿Necesitas una pista?',
                                            style: TextStyle(
                                              color: AppColors.secundario,
                                              fontWeight: FontWeight.w600,
                                              fontSize: hintTextSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_hintVisible) ...[
                                      const SizedBox(height: 10),
                                      _buildHint(context),
                                    ],
                                    const SizedBox(height: 28),
                                    BotonVerificarEjercicio(
                                      enabled:
                                          _selectedIndex != -1 && !_verified,
                                      onPressed: _verify,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(height: sh * 0.04),

                            // Ícono
                            Container(
                              width: iconSize,
                              height: iconSize,
                              constraints: const BoxConstraints(
                                maxWidth: 80,
                                maxHeight: 80,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secundario
                                    .withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.record_voice_over_outlined,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),

                            SizedBox(height: sh * 0.03),

                            // Frase principal
                            _buildPhrase(context, isWide, selectedWord),

                            SizedBox(height: sh * 0.04),

                            // Pista
                            if (_hintVisible) _buildHint(context),

                            const Spacer(),

                            Text(
                              'SELECCIONA LA PALABRA QUE FALTA',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Opciones
                            OptionsGrid(
                              options: _options,
                              selectedIndex: _selectedIndex,
                              correctIndex: _correctIndex,
                              verified: _verified,
                              onSelect: (i) =>
                                  setState(() => _selectedIndex = i),
                            ),

                            const SizedBox(height: 24),

                            // Botón pista
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _hintVisible = !_hintVisible,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: AppColors.secundario,
                                      size: 18,
                                    ),
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
                            ),

                            const SizedBox(height: 20),

                            // Botón verificar
                            BotonVerificarEjercicio(
                              enabled: _selectedIndex != -1 && !_verified,
                              onPressed: _verify,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhrase(BuildContext ctx, bool isWide, String? selectedWord) {
    final TextStyle base = TextStyle(
      fontSize: isWide ? 36 : 30,
      fontWeight: FontWeight.bold,
      color: Theme.of(ctx).colorScheme.onSurface,
    );

    final InlineSpan blank = TextSpan(
      text: selectedWord ?? '_______',
      style: const TextStyle(
        color: AppColors.secundario,
        decoration: TextDecoration.underline,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: base,
                children: [
                  const TextSpan(text: 'Nehuatl '),
                  blank,
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('Nahuatlahtolli', style: base),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '(Hablo Náhuatl)',
          style: TextStyle(
            fontSize: isWide ? 18 : 15,
            color: AppColors.textoSecundario40,
          ),
        ),
      ],
    );
  }

  // FIX: recibe BuildContext como parámetro en lugar de usar context directamente
  Widget _buildHint(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    const double horizontalPadding = 24;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw > 1000 ? 0 : horizontalPadding,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.amarillo1.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.amarillo1, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb, color: AppColors.amarillo1, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _hintText,
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
        ),
      ),
    );
  }
}