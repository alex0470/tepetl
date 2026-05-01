import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/admin/admin_widgets.dart' as admin_widgets;

class GenerarConIAScreen extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;

  const GenerarConIAScreen({
    super.key,
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> suggestedExercises = [
      {
        'title': 'Traducción: Jaguar',
        'level': 'BÁSICO',
        'description': '"El jaguar es el rey de la selva...."',
        'response': 'Ocelotl',
        'culturalContext':
            'En la mitología náhuatl, el jaguar (ocelotl) representaba a Tezcatlipoca.',
        'color': Colors.green,
      },
      {
        'title': 'Parejas: Sonidos',
        'level': 'INTERMEDIO',
        'description': 'Relacionar animal con su onomatopeya...',
        'response': 'Tochtli - Cuicatl',
        'culturalContext':
            'El concepto de la voz animal es fundamental en la poesía náhuatl.',
        'color': Colors.purple,
      },
      {
        'title': 'Completar: Serpiente',
        'level': 'BÁSICO',
        'description': '"La __ emplumada es un dios..."',
        'response': 'Coatl',
        'culturalContext':
            'Quetzalcoatl proviene de Quetzal (ave) y Coatl (serpiente).',
        'color': Colors.cyan,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      appBar: AppBar(
        title: Text('GENERAR CON IA',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            admin_widgets.InputCard(
              title: 'TEMA O PALABRA CLAVE',
              hintText: 'ej. Animales de la selva',
              onGenerate: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generando ejercicios...')));
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EJERCICIOS SUGERIDOS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                admin_widgets.Badge(
                    text: '${suggestedExercises.length} RESULTADOS',
                    color: const Color(0xFFE2F4F2),
                    textColor: const Color(0xFF43706F)),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestedExercises.map((exercise) => admin_widgets.SuggestionCard(
                  cursoId: cursoId,
                  moduloId: moduloId,
                  leccionId: leccionId,
                  title: exercise['title'],
                  level: exercise['level'],
                  description: exercise['description'],
                  response: exercise['response'],
                  culturalContext: exercise['culturalContext'],
                  accentColor: exercise['color'],
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
