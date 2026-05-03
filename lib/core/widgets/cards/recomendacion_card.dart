import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class RecomendacionCard extends StatelessWidget {
  final Map<String, String> rec;
  final bool isDark;
  final bool horizontal;

  const RecomendacionCard({
    super.key,
    required this.rec,
    required this.isDark,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Container(
        margin: EdgeInsets.only(
          right: horizontal ? 0 : 8,
          bottom: horizontal ? 8 : 0,
        ),
        decoration: _cardDecoration(),
        child: horizontal ? _horizontalLayout() : _verticalLayout(),
      ),
    );
  }

  void _showPopup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 700;
    final double dialogMaxHeight = isWide ? 500 : (screenHeight - 56).clamp(0, double.infinity);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor:
              isDark ? AppColors.fondoOscuroSecundario : Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 500 : double.infinity,
              maxHeight: dialogMaxHeight,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: isWide
                  ? _popupHorizontal(context)
                  : _popupVertical(context),
            ),
          ),
        );
      },
    );
  }

  Widget _popupVertical(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _popupImage(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _popupContent(context),
        ),
      ],
    );
  }

  Widget _popupHorizontal(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _popupImage(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _popupContent(context),
        ),
      ],
    );
  }

  Widget _popupImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: Container(
        height: 120,
        width: double.infinity,
        color: isDark
            ? AppColors.fondoOscuro
            : AppColors.extra120,
        child: Icon(
          Icons.image_outlined,
          size: 50,
          color: isDark
              ? AppColors.textoSecundario40
              : AppColors.textoSecundario20,
        ),
      ),
    );
  }

  Widget _popupContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(rec["nivel"]!),

        const SizedBox(height: 8),

        Text(
          rec["titulo"]!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Explora este contenido diseñado para reforzar tu aprendizaje de forma dinámica e interactiva. "
          "Incluye ejemplos prácticos, ejercicios guiados y una experiencia adaptativa que te ayudará a mejorar "
          "tu comprensión del idioma de manera progresiva y efectiva.",
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: isDark
                ? AppColors.textoClaro
                : AppColors.textoSecundario,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secundario,
                  minimumSize: const Size.fromHeight(40),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Inscribirse",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _verticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _image(100),
        Padding(
          padding: const EdgeInsets.all(10),
          child: _info(),
        ),
      ],
    );
  }

  Widget _horizontalLayout() {
    return Row(
      children: [
        _image(100, width: 100),
        const SizedBox(width: 10),
        Expanded(child: _info()),
      ],
    );
  }

  Widget _image(double height, {double width = double.infinity}) {
    return ClipRRect(
      borderRadius: horizontal
          ? const BorderRadius.horizontal(left: Radius.circular(14))
          : const BorderRadius.vertical(top: Radius.circular(14)),
      child: Container(
        height: height,
        width: width,
        color: isDark ? AppColors.fondoOscuro : AppColors.extra120,
        child: Icon(Icons.image_outlined,
            size: 24,
            color: isDark
                ? AppColors.textoSecundario40
                : AppColors.textoSecundario20),
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _badge(rec["nivel"]!),
        const SizedBox(height: 4),
        Text(
          rec["titulo"]!,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.access_time_outlined,
                size: 11,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario),
            const SizedBox(width: 3),
            Text(
              rec["detalle"]!,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: isDark
          ? AppColors.fondoOscuroSecundario
          : AppColors.fondoSecundario,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 2,
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(3, 3),
        )
      ],
    );
  }

  Widget _badge(String nivel) {
    late Color bg;
    late Color fg;

    switch (nivel) {
      case "ACTUAL":
        bg = AppColors.secundario.withValues(alpha: 0.2);
        fg = AppColors.secundario;
        break;
      case "REPASA":
        bg = AppColors.naranja1.withValues(alpha: 0.2);
        fg = AppColors.naranja1;
        break;
      default:
        bg = AppColors.azul1.withValues(alpha: 0.2);
        fg = AppColors.azul1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        nivel,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}