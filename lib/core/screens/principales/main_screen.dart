import 'package:flutter/material.dart';
import 'package:tepetl/core/widgets/bars/bottom_nav.dart';
import 'package:tepetl/core/widgets/bars/inicio_appbar.dart';

// IMPORTA TUS PANTALLAS
import 'contexto_cultural.dart';
import 'inicio.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 2; // Inicio por defecto

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      const DescubrirScreen(),
      const _PlaceholderScreen(title: "Cultura"),
      const InicioScreen(),
      const _PlaceholderScreen(title: "Cursos"),
      const _PlaceholderScreen(title: "Diccionario"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: InicioAppBar(isDark: isDark),

      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNav(
        isDark: isDark,
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() => currentIndex = i);
        },
      ),
    );
  }
}

//
// ── Placeholder para secciones que aún no tienes ─────────────
//

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}