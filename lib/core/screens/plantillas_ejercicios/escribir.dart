import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_verificar_ejercicio.dart';
import 'package:tepetl/core/widgets/popups/respuesta_sheet.dart';
import 'package:tepetl/core/models/modelo_ejercicio.dart';

class PlantillaEscribir extends StatefulWidget {
  final EjercicioModel ejercicio;

  /// Callback al terminar: (esCorrecto)
  final Function(bool isCorrect, bool pistaUsada) onCompletado;

  /// Callback que se dispara la primera vez que el usuario abre la pista
  final VoidCallback? onPistaUsada;

  const PlantillaEscribir({
    super.key,
    required this.ejercicio,
    required this.onCompletado,
    this.onPistaUsada,
  });

  @override
  State<PlantillaEscribir> createState() => _PlantillaEscribirState();
}

class _PlantillaEscribirState extends State<PlantillaEscribir> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hintVisible = false;
  bool _hintReported = false; // evita contar la pista más de una vez
  bool _verified = false;

  late String _correctAnswer;
  late String _hintText;
  late String _contenido;
  late String _palabraNahuatl;
  late String _instruccion;

  @override
  void initState() {
    super.initState();
    _correctAnswer = widget.ejercicio.respuesta;
    _hintText = widget.ejercicio.pista;
    _contenido = widget.ejercicio.contenido;

    final match = RegExp(r"'([^']+)'").firstMatch(_contenido);
    if (match != null) {
      _palabraNahuatl = match.group(1)!;
      _instruccion = _contenido
          .replaceAll("'$_palabraNahuatl'", '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
    } else {
      _palabraNahuatl = '';
      _instruccion = _contenido;
    }
  }

  String _normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');

  void _togglePista() {
    setState(() => _hintVisible = !_hintVisible);

    // Notificar al padre solo la primera vez que se abre la pista
    if (_hintVisible && !_hintReported) {
      _hintReported = true;
      widget.onPistaUsada?.call();
    }
  }

  void _verify() {
    if (_controller.text.trim().isEmpty || _verified) return;

    _focusNode.unfocus();

    final String userInput = _normalize(_controller.text);
    final String correct = _normalize(_correctAnswer);
    final bool isCorrect = userInput == correct;

    setState(() {
      _verified = true;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RespuestaSheet(
        isCorrect: isCorrect,
        explanation: isCorrect
            ? '¡Muy bien! "$_palabraNahuatl" se traduce a "$_correctAnswer".'
            : 'La respuesta era: $_correctAnswer',
        correctAnswer: _correctAnswer,
        onContinue: () => Navigator.of(ctx).pop(),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {
        _verified = false;
        _controller.clear();
      });
      widget.onCompletado(isCorrect, _hintReported);
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
    final bool hasInput = _controller.text.trim().isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
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
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 0 : sw * 0.05,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: sh * 0.03),

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

                            SizedBox(height: sh * 0.02),

                            if (_instruccion.isNotEmpty)
                              Center(
                                child: Text(
                                  _instruccion,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),

                            SizedBox(height: sh * 0.025),

                            if (_palabraNahuatl.isNotEmpty)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secundario
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.secundario
                                          .withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    _palabraNahuatl,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),

                            SizedBox(height: sh * 0.03),

                            Text(
                              'Tu traducción',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 10),

                            _TranslationField(
                              controller: _controller,
                              focusNode: _focusNode,
                              enabled: !_verified,
                              onChanged: (_) => setState(() {}),
                            ),

                            SizedBox(height: sh * 0.035),

                            if (_hintVisible && _hintText.isNotEmpty) ...[
                              _HintBox(text: _hintText),
                              const SizedBox(height: 16),
                            ],

                            if (_hintText.isNotEmpty)
                              GestureDetector(
                                onTap: _togglePista,
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
    final Color fieldBg =
        isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario;

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
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.35),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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