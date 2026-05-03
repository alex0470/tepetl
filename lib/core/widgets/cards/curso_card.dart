import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class CursoCard extends StatelessWidget {
  final Map<String, dynamic> curso;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const CursoCard({
    super.key,
    required this.curso,
    required this.isDark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = curso["porcentaje"] as double;
    final titulo = curso["titulo"] as String? ?? '';
    final imagenUrl = curso["imagenUrl"] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.fondoOscuroSecundario
              : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: AppColors.secundario, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: _CoverImage(url: imagenUrl, titulo: titulo, height: 100),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _badge(curso["nivel"] as String? ?? ''),
                  const SizedBox(height: 5),

                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: pct,
                              strokeWidth: 3,
                              backgroundColor: isDark
                                  ? AppColors.fondoOscuro
                                  : AppColors.extra120,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppColors.secundario),
                            ),
                            Text(
                              pct >= 1.0
                                  ? "✓"
                                  : "${(pct * 100).toInt()}",
                              style: TextStyle(
                                fontSize: pct >= 1.0 ? 11 : 7,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textoClaro
                                    : AppColors.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pct >= 1.0
                              ? "Completado"
                              : "${(pct * 100).toInt()}% completado",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textoClaro
                                : AppColors.textoSecundario,
                          ),
                        ),
                      ),
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

class _CoverImage extends StatelessWidget {
  final String url;
  final String titulo;
  final double height;

  const _CoverImage({
    required this.url,
    required this.titulo,
    required this.height,
  });

  Color _colorFromTitle() {
    const colors = [
      Color(0xFF2D6A4F),
      Color(0xFF1B4332),
      Color(0xFF40916C),
      Color(0xFF1D3557),
      Color(0xFF457B9D),
      Color(0xFF6D4C41),
    ];
    return colors[titulo.length % colors.length];
  }

  Widget _placeholder() {
    final color = _colorFromTitle();
    final initials = titulo.isNotEmpty
        ? titulo.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
    return Container(
      height: height,
      width: double.infinity,
      color: color,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder();
        },
        errorBuilder: (_, _, _) => _placeholder(),
      ),
    );
  }
}
