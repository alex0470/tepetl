import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  /// Callback invocado cuando el usuario elige "Ver artículos primero".
  /// El padre lo usa para cambiar el tab inicial de MainScreen a Cultura (0).
  final VoidCallback? onVerArticulos;

  const OnboardingScreen({super.key, this.onVerArticulos});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Map<String, String>> _pages = [
    {
      'titulo': 'Bienvenido a Tepetl',
      'subtitulo':
          'Aprende el idioma de los antiguos mexicanos y conecta con tu identidad cultural.',
      'imagen': 'assets/imagen2.png',
    },
    {
      'titulo': 'Tu Mentor Inteligente',
      'subtitulo':
          'IA personalizada que analiza tus resultados para guiarte paso a paso en tu aprendizaje del Náhuatl.',
      'imagen': 'assets/asistente.png',
    },
    {
      'titulo': 'Ejercicios Dinámicos',
      'subtitulo':
          'Traduce palabras, relaciona conceptos y completa frases para dominar el idioma a tu propio ritmo.',
      'imagen': 'assets/ejercicios_dina.png',
    },
    {
      'titulo': 'Gana Insignias',
      'subtitulo':
          'Desbloquea contenido exclusivo y mide tu progreso desde principiante hasta intermedio.',
      'imagen': 'assets/insignias.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'onboardingCompletado': true});
      } catch (e) {
        debugPrint('Error actualizando onboarding: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  /// Marca el onboarding completado y señala al padre que cambie al tab de Cultura.
  Future<void> _verArticulos() async {
    // 1. Avisar al padre antes de la operación async para que cambie el tab
    widget.onVerArticulos?.call();
    // 2. Marcar en Firestore (el stream del AuthWrapper reaccionará y quitará el overlay)
    await _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final sw     = MediaQuery.of(context).size.width;
    final isWide = sw > 700;

    // Ancho máximo de la tarjeta: más grande en desktop
    final maxW   = isWide ? 640.0 : 480.0;
    final hPad   = isWide ? 40.0  : 20.0;
    final vPad   = isWide ? 40.0  : 24.0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Capa de blur aislada: solo se repinta cuando cambia el fondo de la app,
          // NO en cada cambio de página del carrusel.
          RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withValues(alpha: 0.52),
              ),
            ),
          ),
          // Contenido dinámico: se repinta en cada setState sin tocar el blur.
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: _buildCard(context, isWide: isWide),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {bool isWide = false}) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isLast  = _currentPage == _pages.length - 1;
    final imgH    = isWide ? 300.0 : 230.0;
    final pad     = isWide ? 36.0  : 28.0;
    final titleSz = isWide ? 26.0  : 21.0;
    final bodySz  = isWide ? 16.0  : 14.0;
    final textH   = isWide ? 140.0 : 118.0;
    final btnH    = isWide ? 52.0  : 46.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 48,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Imagen superior ─────────────────────────────────────────────
          _ImagenSuperior(
            imageAsset: _pages[_currentPage]['imagen']!,
            currentPage: _currentPage,
            height: imgH,
          ),

          // ── Contenido ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 22, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dots de paginación
                Row(
                  children: List.generate(
                    _pages.length,
                    (i) => _buildDot(i),
                  ),
                ),
                const SizedBox(height: 16),

                // Texto deslizante
                SizedBox(
                  height: textH,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    itemCount: _pages.length,
                    itemBuilder: (_, index) {
                      final d = _pages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['titulo']!,
                            style: TextStyle(
                              fontSize: titleSz,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            d['subtitulo']!,
                            style: TextStyle(
                              fontSize: bodySz,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.58),
                              height: 1.6,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // Botón principal
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: btnH,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primario,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isLast ? 'Aprende ahora' : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                // Link omitir
                if (!_isLoading) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: isLast ? _verArticulos : _finishOnboarding,
                      child: Text(
                        isLast
                            ? 'Ver artículos primero'
                            : 'Omitir introducción',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      height: 7,
      width: _currentPage == index ? 22 : 7,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primario
            : Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Imagen superior ────────────────────────────────────────────────────────────

class _ImagenSuperior extends StatelessWidget {
  final String imageAsset;
  final int currentPage;
  final double height;

  const _ImagenSuperior({
    required this.imageAsset,
    required this.currentPage,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.primario.withValues(alpha: 0.07),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            key: ValueKey(currentPage),
            padding: const EdgeInsets.all(32),
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
