import 'package:flutter/material.dart';

class CursoFilters {
  static const List<String> niveles = [
    'Básico',
    'Básico+',
    'Intermedio',
  ];

  static const List<String> categorias = [
    'Saludos',
    'Salud',
    'Astros',
    'Comida',
    'Naturaleza',
    'Animales',
    'Familia',
    'Casa',
    'Números',
    'Colores',
  ];

  static IconData getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'saludos':
        return Icons.waving_hand_rounded;
      case 'salud':
        return Icons.favorite_rounded;
      case 'astros':
        return Icons.stars_rounded;
      case 'comida':
        return Icons.restaurant_rounded;
      case 'naturaleza':
        return Icons.nature_rounded;
      case 'animales':
        return Icons.pets_rounded;
      case 'familia':
        return Icons.people_rounded;
      case 'casa':
        return Icons.home_rounded;
      case 'números':
        return Icons.numbers_rounded;
      case 'colores':
        return Icons.palette_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color getCategoryColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'saludos':
        return Colors.blue;
      case 'salud':
        return Colors.red;
      case 'astros':
        return Colors.indigo;
      case 'comida':
        return Colors.orange;
      case 'naturaleza':
        return Colors.green;
      case 'animales':
        return Colors.amber;
      case 'familia':
        return Colors.pink;
      case 'casa':
        return Colors.brown;
      case 'números':
        return Colors.purple;
      case 'colores':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
