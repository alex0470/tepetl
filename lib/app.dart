import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tepetl/core/screens/usuario/perfil_ajustes.dart';
import 'core/theme/app_theme.dart';
import 'core/screens/inicio/splash_screen.dart';
import 'core/screens/inicio/landing_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Estado global del tema
  ThemeMode _themeMode = ThemeMode.system;

  // Función para cambiar el tema desde los ajustes
  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tepetl: Lenguas Vivas",

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode, // Usamos la variable de estado

      home: kIsWeb 
          ? const LandingPage() 
          : const SplashScreen(),

      routes: {
        "/home": (context) => const LandingPage(),
        // Pasamos la función y el estado actual a la pantalla de ajustes
        "/ajustes": (context) => PerfilAjustesScreen(
          onThemeChanged: toggleTheme,
          currentThemeMode: _themeMode,
        ),
      },
    );
  }
}