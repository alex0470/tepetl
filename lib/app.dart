import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tepetl/core/screens/usuario/perfil_ajustes.dart';
import 'package:tepetl/core/widgets/usuario/wrapper_onboarding.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatefulWidget {
  final ThemeMode initialTheme;

  const MyApp({super.key, required this.initialTheme});

  static _MyAppState of(BuildContext context) => 
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
  }

  ThemeMode get currentTheme => _themeMode;

  Future<void> toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', isDark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tepetl: Lenguas Vivas",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const AuthWrapper(),
      routes: {
        '/ajustes': (_) => const PerfilAjustesScreen(),
      },
    );
  }
}