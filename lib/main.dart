import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Nuevo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Leer preferencias guardadas
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme_mode');
  
  ThemeMode initialTheme = ThemeMode.system; // Por defecto obedece al celular
  if (savedTheme == 'light') initialTheme = ThemeMode.light;
  if (savedTheme == 'dark') initialTheme = ThemeMode.dark;

  // Pasamos el tema inicial a la app
  runApp(MyApp(initialTheme: initialTheme)); 
}