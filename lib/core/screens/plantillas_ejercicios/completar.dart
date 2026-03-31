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

  //Constantes del ejercicio
  static const String _correctAnswer = 'nitlahtoa';
  static const int _correctIndex = 1; // índice en _options
  static const String _hintText =
      'La palabra que buscas significa "hablar". En náhuatl, los verbos en primera persona comienzan con "ni-".';

  static const List<String> _options = [
    'niquihtoa',
    'nitlahtoa',
    'nimitztlazohtla',
  ];

  /// Explicación por índice de opción seleccionada.
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
        builder: (_) => RespuestaSheet(
          isCorrect: isCorrect,
          explanation: _explanations[_selectedIndex],
          correctAnswer: _correctAnswer,
          onContinue: () => Navigator.of(context).pop(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() {
          _verified = false;
          _selectedIndex = -1;
        });
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const PlantillaEscribir(),
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

    final double contentWidth =
        isWide ? (sw * 0.75).clamp(600, 900) : double.infinity;
    final double progressWidth =
        isWide ? (sw * 1.0).clamp(600, 1700) : double.infinity;

    final String? selectedWord =
        _selectedIndex != -1 ? _options[_selectedIndex] : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppbarEjercicios(
              title: 'EXPRESIÓN ESCRITA',
              hearts: _hearts,
              onClose: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const InicioScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),

            //Barra de progreso
            LessonProgressBar(
              lessonLabel: 'LECCIÓN 2',
              progress: 0.45,
              progressWidth: progressWidth,
            ),

            Expanded(
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      SizedBox(height: sh * 0.04),

                      //Ícono
                      Container(
                        width: sw * 0.2,
                        height: sw * 0.2,
                        constraints:
                            const BoxConstraints(maxWidth: 80, maxHeight: 80),
                        decoration: BoxDecoration(
                          color: AppColors.secundario.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.record_voice_over_outlined,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      //Frase principal
                      _buildPhrase(context, isWide, selectedWord),

                      SizedBox(height: sh * 0.04),

                      //Pista
                      if (_hintVisible) _buildHint(),

                      const Spacer(),

                      Text(
                        'SELECCIONA LA PALABRA QUE FALTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 16),

                      //Opciones
                      OptionsGrid(
                        options: _options,
                        selectedIndex: _selectedIndex,
                        correctIndex: _correctIndex,
                        verified: _verified,
                        onSelect: (i) => setState(() => _selectedIndex = i),
                      ),

                      const SizedBox(height: 24),

                      //Botón pista
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 30),
                        child: GestureDetector(
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
                      ),

                      const SizedBox(height: 20),

                      //Botón verificar
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
      fontSize: 30,
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

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: base,
              children: [const TextSpan(text: 'Nehuatl '), blank],
            ),
          ),
          const SizedBox(width: 12),
          Text('Nahuatlahtolli', style: base),
        ],
      );
    }

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: base,
            children: [const TextSpan(text: 'Nehuatl '), blank],
          ),
        ),
        const SizedBox(height: 4),
        Text('Nahuatlahtolli', style: base),
        const SizedBox(height: 8),
        const Text(
          '(Hablo Náhuatl)',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textoSecundario40,
          ),
        ),
      ],
    );
  }

  Widget _buildHint() {
    final double sw = MediaQuery.of(context).size.width;
    const double horizontalPadding = 24;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw > 1000 ? 0 : horizontalPadding),
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