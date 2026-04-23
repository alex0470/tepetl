import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_verificar_ejercicio.dart';
import 'package:tepetl/core/widgets/inputs/respuestas_chips.dart';
import 'package:tepetl/core/widgets/popups/respuesta_sheet.dart';
import 'package:tepetl/core/models/modelo_ejercicio.dart';

class PlantillaCompletar extends StatefulWidget {
  final EjercicioModel ejercicio;

  /// Callback al terminar: (esCorrecto, usedHint)
  final Function(bool isCorrect, bool usedHint) onCompletado;

  /// Callback que se dispara la primera vez que el usuario abre la pista
  final VoidCallback? onPistaUsada;

  const PlantillaCompletar({
    super.key,
    required this.ejercicio,
    required this.onCompletado,
    this.onPistaUsada,
  });

  @override
  State<PlantillaCompletar> createState() => _PlantillaCompletarState();
}

class _PlantillaCompletarState extends State<PlantillaCompletar> {
  int _selectedIndex = -1;
  bool _hintVisible = false;
  bool _hintReported = false; // evita contar la pista más de una vez
  bool _verified = false;

  late String _correctAnswer;
  late int _correctIndex;
  late String _hintText;
  late List<String> _options;
  late String _parte1;
  late String _parte2;

  @override
  void initState() {
    super.initState();
    _correctAnswer = widget.ejercicio.respuesta;
    _hintText = widget.ejercicio.pista;

    _options = List.from(widget.ejercicio.opciones);
    if (!_options.contains(_correctAnswer)) {
      _options.add(_correctAnswer);
    }
    _options.shuffle();
    _correctIndex = _options.indexOf(_correctAnswer);

    List<String> parts = widget.ejercicio.contenido.split('_____');
    if (parts.length >= 2) {
      _parte1 = parts[0];
      _parte2 = parts.length > 2 ? parts.sublist(1).join('_____') : parts[1];
    } else {
      _parte1 = parts.isNotEmpty ? parts[0] : '';
      _parte2 = '';
    }
  }

  void _togglePista() {
    setState(() => _hintVisible = !_hintVisible);

    if (_hintVisible && !_hintReported) {
      _hintReported = true;
      widget.onPistaUsada?.call();
    }
  }

  void _verify() {
    if (_selectedIndex == -1 || _verified) return;

    final bool isCorrect = _correctIndex != -1
        ? _selectedIndex == _correctIndex
        : _options[_selectedIndex] == _correctAnswer;

    setState(() {
      _verified = true;
    });

    final String explanationText = isCorrect
        ? '¡Correcto! "$_correctAnswer" completa la frase adecuadamente.'
        : 'La respuesta correcta era "$_correctAnswer".\n$_hintText';

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => RespuestaSheet(
          isCorrect: isCorrect,
          explanation: explanationText,
          correctAnswer: _correctAnswer,
          onContinue: () => Navigator.of(ctx).pop(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() {
          _verified = false;
          _selectedIndex = -1;
        });
        widget.onCompletado(isCorrect, _hintVisible);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isWide = sw > 1000;

    final double contentWidth = isWide ? sw * 0.96 : double.infinity;
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: isWide
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                    horizontal: 32,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _buildIcon(iconSize),
                                      SizedBox(height: sh * 0.04),
                                      _buildPhrase(
                                          context, isWide, selectedWord),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _buildInstruccion(20),
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
                                      _buildPistaToggle(hintTextSize),
                                      if (_hintVisible &&
                                          _hintText.isNotEmpty) ...[
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
                              _buildIcon(iconSize),
                              SizedBox(height: sh * 0.03),
                              _buildPhrase(context, isWide, selectedWord),
                              SizedBox(height: sh * 0.04),
                              if (_hintVisible && _hintText.isNotEmpty)
                                _buildHint(context),
                              const SizedBox(height: 20),
                              _buildInstruccion(titleFontSize),
                              const SizedBox(height: 16),
                              OptionsGrid(
                                options: _options,
                                selectedIndex: _selectedIndex,
                                correctIndex: _correctIndex,
                                verified: _verified,
                                onSelect: (i) =>
                                    setState(() => _selectedIndex = i),
                              ),
                              const SizedBox(height: 24),
                              _buildPistaToggle(14),
                              const SizedBox(height: 20),
                              BotonVerificarEjercicio(
                                enabled: _selectedIndex != -1 && !_verified,
                                onPressed: _verify,
                              ),
                            ],
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

  Widget _buildIcon(double size) {
    return Container(
      width: size,
      height: size,
      constraints: const BoxConstraints(maxWidth: 80, maxHeight: 80),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.record_voice_over_outlined,
        color: Colors.white,
        size: 38,
      ),
    );
  }

  Widget _buildInstruccion(double fontSize) {
    return Text(
      'SELECCIONA LA PALABRA QUE FALTA',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildPistaToggle(double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: _togglePista,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline,
                color: AppColors.secundario, size: 18),
            const SizedBox(width: 6),
            Text(
              _hintVisible ? 'Ocultar pista' : '¿Necesitas una pista?',
              style: TextStyle(
                color: AppColors.secundario,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhrase(BuildContext ctx, bool isWide, String? selectedWord) {
    final TextStyle base = TextStyle(
      fontSize: isWide ? 36 : 26,
      fontWeight: FontWeight.bold,
      color: Theme.of(ctx).colorScheme.onSurface,
    );

    final InlineSpan blank = TextSpan(
      text: selectedWord ?? '_______',
      style: TextStyle(
        fontSize: isWide ? 36 : 26,
        fontWeight: FontWeight.bold,
        color: AppColors.secundario,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.secundario,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: _parte1),
            blank,
            TextSpan(text: _parte2),
          ],
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }

  Widget _buildHint(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw > 1000 ? 0 : 24),
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
              const Icon(Icons.lightbulb,
                  color: AppColors.amarillo1, size: 18),
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