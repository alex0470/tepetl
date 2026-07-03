import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:tepetl/core/screens/autenticacion/registro.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/cards/feature_card.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // ── Helpers de navegación ─────────────────────────────────────────────────

  void _goLogin(BuildContext context) => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

  void _goRegister(BuildContext context) => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const RegistroScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sw     = MediaQuery.of(context).size.width;
    final isWide = sw > 700;

    // Padding horizontal responsivo para las secciones principales
    final hPad = isWide ? 80.0 : 20.0;

    return Scaffold(
      // ── AppBar ───────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          shadowColor: Colors.black.withValues(alpha: 0.7),
          centerTitle: false,
          titleSpacing: 16,
          title: GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const LandingPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo50.png', width: 28, height: 28),
                const SizedBox(width: 10),
                const Text('TEPETL',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            if (isWide) ...[
              // Desktop: dos botones completos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BotonesSombra(
                  text: 'Iniciar sesión',
                  onPressed: () => _goLogin(context),
                  width: 150,
                  height: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: BotonesSombra(
                  text: 'Registrarse',
                  onPressed: () => _goRegister(context),
                  width: 150,
                  height: 40,
                ),
              ),
            ] else ...[
              // Móvil: botón compacto
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BotonesSombra(
                  text: 'Comenzar',
                  onPressed: () => _goLogin(context),
                  width: 120,
                  height: 36,
                ),
              ),
            ],
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isWide ? 40 : 24),

            // ── Sección Hero ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: isWide ? 40 : 24),
              child: isWide
                  ? _heroWide(context)
                  : _heroNarrow(context, sw),
            ),

            SizedBox(height: isWide ? 40 : 24),

            // ── Sección Features (fondo primario) ─────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: isWide ? 80 : 48, horizontal: hPad),
              color: AppColors.primario,
              child: Column(
                children: [
                  const Text(
                    'TECNOLOGÍA ANCESTRAL',
                    style: TextStyle(
                      color: AppColors.verde1,
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Inteligencia Artificial para lenguas originarias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWide ? 36 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Nuestra plataforma utiliza algoritmos avanzados adaptados específicamente para la fonética y gramática del Náhuatl.',
                    style: TextStyle(color: AppColors.textoSecundario20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: const [
                      FeatureCardDark(
                        icon: Icons.smart_toy,
                        title: 'Retroalimentación Inteligente',
                        desc:
                            'Recibe comentarios automáticos al finalizar ejercicios para mejorar tu aprendizaje y comprensión del idioma.',
                      ),
                      FeatureCardDark(
                        icon: Icons.edit,
                        title: 'Escritura Inteligente',
                        desc:
                            'Practica la gramática con correcciones automáticas y sugerencias contextuales basadas en textos clásicos y modernos.',
                      ),
                      FeatureCardDark(
                        icon: Icons.psychology,
                        title: 'Aprendizaje Personalizado',
                        desc:
                            'Lecciones que se adaptan a tu ritmo, intereses culturales y nivel de conocimiento previo.',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Sección CTA (Únete) ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: isWide ? 80 : 48, horizontal: hPad),
              child: Column(
                children: [
                  Text(
                    'Únete a la comunidad',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Empieza hoy mismo tu viaje por el mundo del Náhuatl y ayuda a preservar nuestra herencia lingüística.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  BotonesSombra(
                    text: 'Regístrate Gratis',
                    onPressed: () => _goRegister(context),
                    width: 250,
                    height: 50,
                    backgroundColor: AppColors.primario,
                    textColor: Colors.white,
                    hasShadow: true,
                  ),
                ],
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: 60, horizontal: hPad),
              color: AppColors.primario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 32,
                    spacing: 40,
                    children: [
                      SizedBox(
                        width: isWide ? 250 : double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/logob50.png',
                                    width: 25, height: 25),
                                const SizedBox(width: 10),
                                const Text(
                                  'TEPETL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Preservando la lengua y cultura Náhuatl a través de la tecnología y la innovación educativa.',
                              style: TextStyle(
                                  color: AppColors.textoSecundario40),
                            ),
                          ],
                        ),
                      ),
                      _footerColumn('Plataforma',
                          ['Metodología', 'Cultura', 'Planes', 'Para Escuelas'],
                          isWide: isWide),
                      _footerColumn('Recursos',
                          ['Blog', 'Diccionario', 'Comunidad', 'Soporte'],
                          isWide: isWide),
                      _footerColumn(
                          'Legal', ['Privacidad', 'Términos', 'Cookies'],
                          isWide: isWide),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: AppColors.fondoOscuro),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 12,
                    children: [
                      const Text(
                        '© 2026 TEPETL.',
                        style: TextStyle(
                            color: AppColors.textoSecundario20, fontSize: 12),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.facebook,
                              color: AppColors.textoSecundario20, size: 18),
                          SizedBox(width: 16),
                          Icon(Icons.reddit,
                              color: AppColors.textoSecundario20, size: 18),
                          SizedBox(width: 16),
                          Icon(Icons.chat_bubble,
                              color: AppColors.textoSecundario20, size: 18),
                        ],
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

  // ── Hero Desktop ──────────────────────────────────────────────────────────

  Widget _heroWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aprende Náhuatl',
                  style: Theme.of(context).textTheme.titleLarge),
              const Text(
                'con el poder de la IA',
                style: TextStyle(
                  color: AppColors.verde1,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Conecta con tus raíces y domina la lengua ancestral con la tecnología moderna.\nUna experiencia de aprendizaje única que une el pasado y el futuro.',
              ),
              const SizedBox(height: 60),
              _heroButtons(context),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Historia_general_de_las_cosas_de_nueva_Espa%C3%B1a_page_406_2.png/250px-Historia_general_de_las_cosas_de_nueva_Espa%C3%B1a_page_406_2.png',
                width: 420,
                fit: BoxFit.contain,
                cacheWidth: 840,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero Móvil ────────────────────────────────────────────────────────────

  Widget _heroNarrow(BuildContext context, double sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Imagen primero en móvil
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Historia_general_de_las_cosas_de_nueva_Espa%C3%B1a_page_406_2.png/250px-Historia_general_de_las_cosas_de_nueva_Espa%C3%B1a_page_406_2.png',
            width: (sw * 0.6).clamp(160, 260),
            fit: BoxFit.contain,
            cacheWidth: 520,
          ),
        ),
        const SizedBox(height: 28),
        Text('Aprende Náhuatl',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        const Text(
          'con el poder de la IA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.verde1,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Conecta con tus raíces y domina la lengua ancestral con la tecnología moderna. Una experiencia única que une el pasado y el futuro.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _heroButtons(context, narrow: true),
      ],
    );
  }

  // ── Botones Hero (compartidos) ────────────────────────────────────────────

  Widget _heroButtons(BuildContext context, {bool narrow = false}) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: narrow ? WrapAlignment.center : WrapAlignment.start,
      children: [
        BotonesSombra(
          text: 'Comenzar Ahora',
          onPressed: () => _goRegister(context),
          width: narrow ? 180 : 200,
          height: 50,
        ),
        BotonesSombra(
          text: 'Explorar',
          onPressed: () {},
          width: narrow ? 180 : 200,
          height: 50,
          backgroundColor: AppColors.secundario.withValues(alpha: 0.3),
          textColor: Colors.black,
          hasShadow: false,
        ),
      ],
    );
  }

  // ── Footer column ─────────────────────────────────────────────────────────

  Widget _footerColumn(String title, List<String> items,
      {bool isWide = true}) {
    return SizedBox(
      width: isWide ? 160 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style:
                    const TextStyle(color: AppColors.textoSecundario20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
