import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/models/curso_models.dart';
import 'package:tepetl/core/services/cursos_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class Label extends StatelessWidget {
  final String text;
  const Label({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final Widget? suffixWidget;
  final int maxLines;
  final TextEditingController? controller;

  const AppTextField({
    required this.hint,
    this.icon,
    this.suffixWidget,
    this.maxLines = 1,
    this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textoSecundario.withValues(alpha: 0.6), fontSize: 14),
            suffixIcon: suffixWidget != null
                ? null
                : (icon != null ? Icon(icon, color: AppColors.textoSecundario.withValues(alpha: 0.6)) : null),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.textoSecundario40),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.textoSecundario40),
            ),
          ),
        ),
        if (suffixWidget != null)
          Positioned(
            bottom: 4,
            right: 4,
            child: suffixWidget!,
          ),
      ],
    );
  }
}

class NivelDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const NivelDropdown({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: ['Básico', 'Básico+', 'Intermedio']
            .map((nivel) => DropdownMenuItem(value: nivel, child: Text(nivel, style: TextStyle(fontSize: 14, color: AppColors.textoSecundario.withValues(alpha: 0.6))),))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class ModuleCardAdmin extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ModuleCardAdmin({
    required this.index,
    required this.title,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('$index',
                style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.secundario,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Toca para ver ejercicios',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 20, color: AppColors.textoSecundario40),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.rojo1),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class LeccionCardAdmin extends StatelessWidget {
  final int index;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const LeccionCardAdmin({
    required this.index,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(Icons.menu_book_outlined,
                color: AppColors.secundario, size: 20),
          ),
        ),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
            descripcion.isNotEmpty ? descripcion : 'Toca para ver ejercicios',
            style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario40),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.textoSecundario40),
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.rojo1),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class CursoAdminCard extends StatelessWidget {
  final CursoModel curso;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onVerModulos;

  const CursoAdminCard({
    required this.curso,
    required this.onEditar,
    required this.onEliminar,
    required this.onVerModulos,
    super.key,
  });

  Color get nivelColor {
    switch (curso.nivel) {
      case 'Básico':
        return AppColors.secundario;
      case 'Básico+':
        return AppColors.azulAqua;
      case 'Intermedio':
        return AppColors.amarillo1;
      default:
        return AppColors.textoSecundario40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onVerModulos,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: curso.imagenUrl.isNotEmpty
                      ? Image.network(
                          curso.imagenUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _iconFallback(nivelColor),
                        )
                      : _iconFallback(nivelColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(curso.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Nivel: ${curso.nivel}',
                          style:
                              const TextStyle(color: AppColors.textoSecundario40, fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEditar,
                      child: const Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.textoSecundario40),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: onEliminar,
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.rojo1),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.view_module_outlined,
                        size: 16, color: AppColors.textoSecundario40),
                    const SizedBox(width: 6),
                    FutureBuilder<int>(
                      future: CursosService.contarModulos(curso.id),
                      builder: (context, snap) => Text(
                        '${snap.data ?? '...'} módulos',
                        style:
                            const TextStyle(color: AppColors.textoSecundario40, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: curso.publicado
                        ? AppColors.verde1.withValues(alpha: 0.1)
                        : AppColors.naranja1.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    curso.publicado ? 'PUBLICADO' : 'BORRADOR',
                    style: TextStyle(
                      color: curso.publicado ? AppColors.secundario : AppColors.naranja1,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconFallback(Color nivelColor) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: nivelColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.import_contacts, color: nivelColor),
      );
}

class EjercicioCardAdmin extends StatelessWidget {
  final String contenido;
  final String tipo;
  final String dificultad;
  final String respuesta;
  final String pista;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EjercicioCardAdmin({
    required this.contenido,
    required this.tipo,
    required this.dificultad,
    required this.respuesta,
    required this.pista,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  IconData get tipoIcon {
    switch (tipo) {
      case 'leer_escribir':
      case 'leer_y_escribir':
        return Icons.edit_note_outlined;
      case 'imagen_y_palabra':
        return Icons.image_outlined;
      case 'escuchar_y_hablar':
        return Icons.spatial_audio_outlined;
      case 'completar_frase':
        return Icons.text_fields_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  Color dificultadColor(BuildContext context) {
    switch (dificultad.toLowerCase()) {
      case 'basico':
      case 'básico':
      case 'permisivo':
        return AppColors.verde1;
      case 'intermedio':
      case 'equilibrado':
        return AppColors.naranja1;
      case 'avanzado':
      case 'estricto':
        return AppColors.rojo1;
      default:
        return AppColors.textoSecundario40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final diffColor = dificultadColor(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secundario.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tipoIcon, color: AppColors.secundario, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipo.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.secundario,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dificultad.toUpperCase(),
                          style: TextStyle(
                              color: diffColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.rojo1),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              contenido,
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (respuesta.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secundario.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.secundario),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Respuesta: $respuesta',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secundario,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (pista.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 13, color: AppColors.amarillo1),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Pista: $pista',
                      style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final String cursoId;
  final String moduloId;
  final String leccionId;
  final String title;
  final String level;
  final String description;
  final String response;
  final String culturalContext;
  final Color accentColor;

  const SuggestionCard({
    required this.cursoId,
    required this.moduloId,
    required this.leccionId,
    required this.title,
    required this.level,
    required this.description,
    required this.response,
    required this.culturalContext,
    required this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              Badge(
                  text: level,
                  color: accentColor.withValues(alpha: 0.1),
                  textColor: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(color: AppColors.textoSecundario40, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textoSecundario40.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Respuesta:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(response,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                                text: 'Contexto Cultural: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoSecundario40,
                                    fontSize: 11)),
                            TextSpan(
                                text: culturalContext,
                                style: TextStyle(
                                    color: AppColors.textoSecundario40, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.textoSecundario40),
                  label: const Text('Editar',
                      style: TextStyle(color: AppColors.textoSecundario40)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await CursosService.crearEjercicio(
                      cursoId,
                      moduloId,
                      leccionId,
                      EjercicioModel(
                        id: '',
                        tipoEjercicio: 'ia_generado',
                        contenido: description,
                        dificultad: level,
                        respuesta: response,
                        pista: culturalContext,
                        creadoPor: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ejercicio añadido')));
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline,
                      size: 16, color: Colors.white),
                  label: const Text('Añadir',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secundario,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InputCard extends StatelessWidget {
  final String title;
  final String hintText;
  final VoidCallback onGenerate;

  const InputCard({
    required this.title,
    required this.hintText,
    required this.onGenerate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(text: title),
          AppTextField(hint: hintText, icon: Icons.edit_outlined),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGenerate,
              icon:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              label: const Text('Generar con IA',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secundario,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const MediaButton({required this.text, required this.icon, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed ?? () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secundario, size: 30),
          const SizedBox(height: 12),
          Text(text,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ImageOptionCard extends StatelessWidget {
  final int index;
  final bool isCorrect;
  final VoidCallback onCorrected;

  const ImageOptionCard({
    required this.index,
    required this.isCorrect,
    required this.onCorrected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textoSecundario40),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              MediaButton(text: 'SUBIR IMAGEN', icon: Icons.image_outlined),
              const SizedBox(height: 12),
              AppTextField(hint: 'Texto Alt (Ej. Montaña)'),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onCorrected,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: isCorrect
                    ? const Icon(Icons.check_circle,
                        color: AppColors.secundario, size: 24)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionFraseCard extends StatelessWidget {
  final int index;
  final bool isCorrect;
  final int groupValue;
  final ValueChanged<int?> onChanged;
  final TextEditingController controller;

  const OptionFraseCard({
    required this.index,
    required this.isCorrect,
    required this.groupValue,
    required this.onChanged,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCorrect
                ? AppColors.secundario.withValues(alpha: 0.5)
                : AppColors.textoSecundario40.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: AppColors.secundario,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Opción ${index + 1}',
                hintStyle: TextStyle(color: AppColors.textoSecundario40, fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsentCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;

  const ConsentCheckbox({
    required this.checked,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secundario.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: onChanged,
            activeColor: AppColors.secundario,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                'Acepto que estos datos sean utilizados para mejorar el modelo de IA de la plataforma.',
                style: TextStyle(color: AppColors.secundario, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool isSaving;

  const SaveButton({required this.onSave, required this.isSaving, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onSave,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_outlined, color: Colors.white),
        label: Text(isSaving ? 'Guardando...' : 'Guardar Ejercicio',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secundario,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const Badge({
    required this.text,
    required this.color,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
