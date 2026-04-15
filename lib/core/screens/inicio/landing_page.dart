import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:tepetl/core/screens/autenticacion/registro.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/cards/feature_card.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          shadowColor: Colors.black.withValues(alpha: 0.7),
          centerTitle: false,
          titleSpacing: 16,

          title: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const LandingPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/logo50.png",
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  "TEPETL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: BotonesSombra(
                    text: "Iniciar sesión",
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) => const LoginScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    width: 150,
                    height: 40,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BotonesSombra(
                    text: "Registrarse",
                    onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                          pageBuilder: (_, _, _) => const RegistroScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    width: 150,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(80),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aprende Náhuatl",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        Text(
                          "con el poder de la IA",
                          style: TextStyle(
                            color: AppColors.verde1,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Conecta con tus raíces y domina la lengua ancestral con la tecnología moderna. \nUna experiencia de aprendizaje única que une el pasado y el futuro.",
                        ),

                        const SizedBox(height: 60),

                        Row(
                          children: [
                            BotonesSombra(
                              text: "Comenzar Ahora",
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, _, _) => const RegistroScreen(),
                                    ),
                                  );
                              },
                              width: 200,
                              height: 50,
                            ),

                            const SizedBox(width: 20),

                            BotonesSombra(
                              text: "Explorar",
                              onPressed: () {},
                              width: 200,
                              height: 50,
                              backgroundColor: AppColors.secundario.withValues(alpha: 0.3),
                              textColor: Colors.black,
                              hasShadow: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  const SizedBox(width: 40),

                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Historia_general_de_las_cosas_de_nueva_Espa%C3%B1a_page_406_2.png/250px-Historia_general_de_las_cosas_de_nueva_Espa%C3%B1a_page_406_2.png",
                          width: 420,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
              color: AppColors.primario,
              child: Column(
                children: [

                  const Text(
                    "TECNOLOGÍA ANCESTRAL",
                    style: TextStyle(
                      color: AppColors.verde1,
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Inteligencia Artificial para lenguas originarias",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Nuestra plataforma utiliza algoritmos avanzados adaptados específicamente para la fonética y gramática del Náhuatl.",
                    style: TextStyle(
                      color: AppColors.textoSecundario20,
                    ),
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
                        title: "Retroalimentación Inteligente",
                        desc:
                            "Recibe comentarios automáticos al finalizar ejercicios para mejorar tu aprendizaje y comprensión del idioma.",
                      ),

                      FeatureCardDark(
                        icon: Icons.edit,
                        title: "Escritura Inteligente",
                        desc:
                            "Practica la gramática con correcciones automáticas y sugerencias contextuales basadas en textos clasicos y modernos.",
                      ),

                      FeatureCardDark(
                        icon: Icons.psychology,
                        title: "Aprendizaje Personalizado",
                        desc:
                            "Lecciones que se adaptan a tu ritmo, intereses culturales y nivel de conocimiento previo",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Text(
                    "Únete a la comunidad",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Text(
                  "Empieza hoy mismo tu viaje por el mundo del Náhuatl y ayuda a preservar nuestra herencia lingüistica.",
                  ),

                  SizedBox(height: 30),

                  BotonesSombra(
                    text: "Registrate Gratis",
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) => const RegistroScreen(),
                          ),
                      );
                    },
                    width: 250,
                    height: 50,
                    backgroundColor: AppColors.primario,
                    textColor: Colors.white,
                    hasShadow: true,
                    ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
              color: AppColors.primario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 40,
                    spacing: 60,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/logob50.png",
                                  width: 25,
                                  height: 25,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "TEPETL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Preservando la lengua y cultura Náhuatl a través de la tecnología y la innovación educativa.",
                              style: TextStyle(
                                color: AppColors.textoSecundario40,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _footerColumn(
                        "Plataforma",
                        ["Metodología", "Cultura", "Planes", "Para Escuelas"],
                      ),

                      _footerColumn(
                        "Recursos",
                        ["Blog", "Diccionario", "Comunidad", "Soporte"],
                      ),

                      _footerColumn(
                        "Legal",
                        ["Privacidad", "Términos", "Cookies"],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Divider(color: AppColors.fondoOscuro),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "© 2026 TEPETL.",
                        style: TextStyle(
                          color: AppColors.textoSecundario20,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.facebook, color: AppColors.textoSecundario20, size: 18),
                          SizedBox(width: 16),
                          Icon(Icons.reddit, color: AppColors.textoSecundario20, size: 18),
                          SizedBox(width: 16),
                          Icon(Icons.chat_bubble, color: AppColors.textoSecundario20, size: 18),
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

  Widget _footerColumn(String title, List<String> items) {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: const TextStyle(
                  color: AppColors.textoSecundario20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}