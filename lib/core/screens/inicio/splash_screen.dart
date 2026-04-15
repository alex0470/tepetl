import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/services/firestore_service.dart';
import 'dart:async';

import 'package:tepetl/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _lightGray = Color(0x99E0E0E0);

  // ── estado ──
  bool _showLogo = false;
  double _progress = 0.0;

  late AnimationController _zoomTextCtrl;
  late Animation<double> _scaleText;

  late AnimationController _fadeLogoCtrl;
  late AnimationController _zoomLogoCtrl;
  late Animation<double> _fadeLogo;
  late Animation<double> _scaleLogo;

  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    _zoomTextCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleText = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _zoomTextCtrl, curve: Curves.easeOutBack),
    );

    _fadeLogoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeLogo = CurvedAnimation(parent: _fadeLogoCtrl, curve: Curves.easeIn);

    _zoomLogoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleLogo = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _zoomLogoCtrl, curve: Curves.easeOutBack),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    _zoomTextCtrl.forward();

    await _animateProgress(from: 0.0, to: 0.50, durationMs: 2000);

    setState(() => _showLogo = true);
    _fadeLogoCtrl.forward();
    _zoomLogoCtrl.forward();

    await _animateProgress(from: 0.50, to: 1.0, durationMs: 1800);

    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      Widget nextScreen;

      if (user != null) {
        final firestore = FirestoreService();
        String rol = await firestore.getUserRole(user.uid);
        bool esAdmin = (rol == 'admin');
        nextScreen = MainScreen(isAdmin: esAdmin);
      } else {
        nextScreen = const LoginScreen();
      }

      // Verificamos nuevamente mounted por si el await de getUserRole tardó
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => nextScreen,
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  Future<void> _animateProgress({
    required double from,
    required double to,
    required int durationMs,
  }) async {
    const int steps = 60;
    final double stepValue = (to - from) / steps;
    final int stepDelay = durationMs ~/ steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDelay));
      if (!mounted) return;
      setState(() {
        _progress = (from + stepValue * (i + 1)).clamp(0.0, 1.0);
      });
    }
  }

  @override
  void dispose() {
    _zoomTextCtrl.dispose();
    _fadeLogoCtrl.dispose();
    _zoomLogoCtrl.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _showLogo
                    ? FadeTransition(
                        opacity: _fadeLogo,
                        child: ScaleTransition(
                          scale: _scaleLogo,
                          child: _phase2(),
                        ),
                      )
                    : ScaleTransition(
                        scale: _scaleText,
                        child: _phase1(),
                      ),
              ),
            ),
            _buildProgressSection(),
          ],
        ),
      ),
    );
  }

  Widget _phase1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TEPETL',
          style: TextStyle(
            color: AppColors.primario,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'APRENDE NÁHUATL',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _phase2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Image.asset("assets/logo800.png"),
        ),
        const SizedBox(height: 20),
        Text(
          'TEPETL',
          style: TextStyle(
            color: AppColors.primario,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'APRENDE NÁHUATL',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final int percent = (_progress * 100).round();
    final String label = _showLogo ? 'Espera un momento' : 'Cargando TEPETL';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: _lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primario,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'v0.0.1',
              style: TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}