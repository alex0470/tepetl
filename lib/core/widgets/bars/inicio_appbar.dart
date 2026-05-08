import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/screens/usuario/racha_diaria_screen.dart';
import 'package:tepetl/core/services/racha_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/timers/vidas_timer.dart';

class InicioAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isDark;

  const InicioAppBar({super.key, required this.isDark});

  @override
  State<InicioAppBar> createState() => _InicioAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InicioAppBarState extends State<InicioAppBar> {
  String _iniciales = '';
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data() ?? {};
      final nombre = data['nombre'] as String? ?? '';
      final rol = (data['rol'] as String? ?? '').toLowerCase();
      if (mounted) {
        setState(() {
          _iniciales = _calcularIniciales(nombre);
          _esAdmin = rol == 'admin';
        });
      }
    } catch (e) {
      debugPrint('InicioAppBar: error cargando usuario: $e');
    }
  }

  String _calcularIniciales(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isDark ? AppColors.fondoOscuroSecundario : Colors.white;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      titleSpacing: 6,
      title: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/logo50.png", width: 28, height: 28),
            const SizedBox(width: 10),
            const Text(
              "TEPETL",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primario,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!_esAdmin) ...[
          const Center(child: WidgetCorazonesTimer()),
          const SizedBox(width: 6),
          _ChipRacha(),
          const SizedBox(width: 6),
        ],
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, "/ajustes"),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: widget.isDark
                      ? AppColors.fondoOscuro
                      : AppColors.fondoSecundario,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _iniciales.isEmpty ? 'U' : _iniciales,
                      style: const TextStyle(
                        color: AppColors.primario,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Chip de racha ─────────────────────────────────────────────────────────────

class _ChipRacha extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatosRacha>(
      stream: RachaService.streamRacha(),
      builder: (context, snap) {
        final datos = snap.data ?? DatosRacha.vacio;
        final racha = datos.rachaActual;
        final activa = datos.rachaActiva;

        final color = activa ? AppColors.naranja1 : Colors.grey.shade400;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RachaDiariaScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, size: 15, color: color),
                const SizedBox(width: 3),
                Text(
                  '$racha',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
