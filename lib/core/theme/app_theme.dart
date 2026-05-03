import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  //TEMA CLARO
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: Colors.white,

    primaryColor: AppColors.primario,

    fontFamily: "SpaceGrotesk",

    colorScheme: const ColorScheme.light(
      primary: AppColors.primario,
      secondary: AppColors.secundario,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 6,
      centerTitle: true,
      titleTextStyle: TextStyle(color: AppColors.primario, fontSize: 24, fontWeight: FontWeight.bold),
      surfaceTintColor: Colors.transparent,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 20,
        color: AppColors.textoSecundario,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: AppColors.textoSecundario,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.secundario,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secundario,
        side: const BorderSide(color: AppColors.secundario),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    cardColor: AppColors.fondoSecundario,
  );



  //TEMA OSCURO
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.fondoOscuro,

    primaryColor: AppColors.secundario,

    fontFamily: "SpaceGrotesk",

    colorScheme: const ColorScheme.dark(
      primary: AppColors.secundario,
      secondary: AppColors.primario,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.fondoOscuro,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: AppColors.primario, fontSize: 24, fontWeight: FontWeight.bold),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 20,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: AppColors.textoClaro,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.secundario,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secundario,
        side: const BorderSide(color: AppColors.secundario),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    cardColor: AppColors.fondoOscuroSecundario,
  );
}