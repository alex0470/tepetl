import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tepetl/core/screens/usuario/perfil_ajustes.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/screens/inicio/splash_screen.dart';
import 'core/screens/inicio/landing_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

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
      themeMode: _themeMode,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras Firebase verifica la sesión (especialmente útil en Web)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si snapshot tiene datos, significa que el usuario está autenticado
          if (snapshot.hasData) {
            return const MainScreen();
          }

          // Si no hay datos, mostramos la Landing o Splash según la plataforma
          return kIsWeb ? const LandingPage() : const SplashScreen();
        },
      ),

      routes: {
        "/home": (context) => const LandingPage(),
        "/ajustes": (context) => PerfilAjustesScreen(
          onThemeChanged: toggleTheme,
          currentThemeMode: _themeMode,
        ),
      },
    );
  }
}