import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/theme/app_theme.dart';
import 'core/screens/inicio/splash_screen.dart';
import 'core/screens/inicio/landing_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tepetl: Lenguas Vivas",

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: kIsWeb 
          ? const LandingPage() 
          : const SplashScreen(),

      routes: {
        "/home": (context) => const LandingPage(),
      },
    );
  }
}