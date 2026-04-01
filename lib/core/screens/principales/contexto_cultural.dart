import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class DescubrirScreen extends StatelessWidget {
  const DescubrirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.04),
          child: Center(
            child: SizedBox(
              width: sw > 700 ? 600 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroCard(context, isDark),

                  const SizedBox(height: 20),

                  _sectionTitle("¿Lo sabías?", isDark),

                  const SizedBox(height: 12),

                  _infoCard(
                    isDark,
                    titulo: "El concepto de 'Teotl'",
                    descripcion:
                        "Entendiendo la dinámica, vivificando y eternamente...",
                    image: "https://69cd7410079511ce6100f7d7.imgix.net/fire.png?w=1024&h=1024",
                  ),

                  _infoCard(
                    isDark,
                    titulo: "Flores y música",
                    descripcion:
                        "'Xochitl, Cuicatl' - La metáfora de la poesía...",
                    image: "https://69cd7410079511ce6100f7d7.imgix.net/flower.png?w=1024&h=1024",
                  ),

                  _infoCard(
                    isDark,
                    titulo: "Lluvia de Tlaloc",
                    descripcion:
                        "La deidad de la lluvia y lo terrenal...",
                    image: "https://69cd7410079511ce6100f7d7.imgix.net/lluvia-cayendo-sobre-plantas-866138.png?w=1024&h=1024",
                  ),

                  const SizedBox(height: 20),

                  _quizCard(isDark),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //
  // ── HERO (IGUAL A LA IMAGEN) ───────────────────────────────
  //

  Widget _heroCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Image.network(
              "https://69cd7410079511ce6100f7d7.imgix.net/varias-monta%C3%B1as-con-muchos-arboles-y-un-atardecer-al-fondo-396971.png?w=1024&h=1024",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Overlay oscuro
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent
                  ],
                ),
              ),
            ),

            // Texto
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "COSMOVISIÓN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "La Montaña en el Pensamiento Náhuatl",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // Botón
            Positioned(
              bottom: 12,
              right: 12,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secundario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Leer artículo"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //
  // ── CARD INFO ──────────────────────────────────────────────
  //

  Widget _infoCard(bool isDark,
      {required String titulo,
      required String descripcion,
      required String image}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textoClaro
                        : AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textoClaro
                        : AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Aprende más...",
                  style: TextStyle(
                    color: AppColors.secundario,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }

  //
  // ── QUIZ CARD ──────────────────────────────────────────────
  //

  Widget _quizCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Cuestionario de cultura diaria",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Pon a prueba tus conocimientos sobre los mitos",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.secundario,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.play_arrow, color: Colors.white),
          )
        ],
      ),
    );
  }

  //
  // ── TITULO ────────────────────────────────────────────────
  //

  Widget _sectionTitle(String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.secundario),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color:
                isDark ? AppColors.textoClaro : AppColors.textoSecundario,
          ),
        ),
      ],
    );
  }
}