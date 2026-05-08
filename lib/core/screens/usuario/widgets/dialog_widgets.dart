import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

EdgeInsets dialogInsetPadding(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w > 700) {
    return EdgeInsets.symmetric(horizontal: w * 0.20, vertical: 24);
  }
  return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
}

// ── Encabezado de diálogo ─────────────────────────────────────────────────────

class DialogEncabezado extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const DialogEncabezado({
    super.key,
    required this.titulo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: AppColors.secundario, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botones de acción (Cancelar / Guardar) ────────────────────────────────────

class DialogAcciones extends StatelessWidget {
  final VoidCallback onGuardar;

  const DialogAcciones({super.key, required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.secundario.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onGuardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secundario,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ── Campo de texto ────────────────────────────────────────────────────────────

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;
  final TextInputType? keyboardType;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    required this.isDark,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: isDark ? AppColors.fondoOscuro : AppColors.fondoSecundario,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secundario, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ── Campo de contraseña ───────────────────────────────────────────────────────

class CampoContrasena extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;
  final bool visible;
  final VoidCallback onToggle;

  const CampoContrasena({
    super.key,
    required this.label,
    required this.controller,
    required this.isDark,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: isDark ? AppColors.fondoOscuro : AppColors.fondoSecundario,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secundario, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ── Fila con switch ───────────────────────────────────────────────────────────

class FilaSwitch extends StatelessWidget {
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FilaSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: AppColors.secundario, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Opción de seguridad ───────────────────────────────────────────────────────

class OpcionSeguridad extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? sub;
  final VoidCallback onTap;
  final Color? color;

  const OpcionSeguridad({
    super.key,
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.sub,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icono, color: c, size: 18),
      ),
      title: Text(
        titulo,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c),
      ),
      subtitle: sub != null
          ? Text(
              sub!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: c.withValues(alpha: 0.5), size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
