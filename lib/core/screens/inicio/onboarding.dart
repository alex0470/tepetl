import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

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
      'imagen': 'assets/imagen3.png',
    },
    {
      'titulo': 'Aprende con Ejercicios Dinámicos',
      'subtitulo':
          'Resuelve retos interactivos, traduce palabras diversas, relaciona palabras y completa frases para dominar el idioma a tu propio ritmo.',
      'imagen': 'assets/logo.png',
    },
    {
      'titulo': 'Gana insignias mientras conectas con las raíces de México',
      'subtitulo':
          'Desbloquea contenido exclusivo y mide tu progreso desde principiante hasta avanzado.',
      'imagen': 'assets/logo.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: _pages[index],
                    isLastPage: index == _pages.length - 1,
                  );
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo50.png', height: 24),
              const SizedBox(width: 8),
              Text(
                'TEPETL',
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppColors.primario),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                List.generate(_pages.length, (index) => _buildDot(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primario
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFooter() {
    bool isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        children: [
          _isLoading
              ? const CircularProgressIndicator()
              : BotonesSombra(
                  text: isLast ? 'Aprende ahora' : 'Siguiente',
                  onPressed: _nextPage,
                  backgroundColor: AppColors.primario,
                  width: double.infinity,
                ),
          const SizedBox(height: 12),
          if (!_isLoading)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                isLast ? 'Ver artículos primero' : 'Omitir introducción',
                style: TextStyle(
                  color: AppColors.primario.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Map<String, String> data;
  final bool isLastPage;

  const _OnboardingPage({required this.data, required this.isLastPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 90),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  data['imagen']!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            data['titulo']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['subtitulo']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}