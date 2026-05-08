import 'package:flutter/material.dart';
import 'package:tepetl/app.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:tepetl/core/screens/usuario/dialogs/editar_perfil_dialog.dart';
import 'package:tepetl/core/screens/usuario/dialogs/idioma_dialog.dart';
import 'package:tepetl/core/screens/usuario/dialogs/notificaciones_dialog.dart';
import 'package:tepetl/core/screens/usuario/dialogs/preferencias_dialog.dart';
import 'package:tepetl/core/screens/usuario/dialogs/privacidad_seguridad_dialog.dart';
import 'package:tepetl/core/screens/usuario/perfil_detalle_screen.dart';
import 'package:tepetl/core/screens/usuario/racha_diaria_screen.dart';
import 'package:tepetl/core/screens/usuario/widgets/ajustes_widgets.dart';
import 'package:tepetl/core/services/insignias_service.dart';
import 'package:tepetl/core/services/perfil_service.dart';
import 'package:tepetl/core/services/racha_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

class PerfilAjustesScreen extends StatefulWidget {
  const PerfilAjustesScreen({super.key});

  @override
  State<PerfilAjustesScreen> createState() => _PerfilAjustesScreenState();
}

class _PerfilAjustesScreenState extends State<PerfilAjustesScreen> {
  String _nombre  = 'Cargando...';
  String _rol     = '';
  String _nivel   = '';
  String _inicial = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await PerfilService.cargarDatos();
    if (!mounted) return;

    if (datos == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: const RouteSettings(name: '/'),
        ),
        (route) => false,
      );
      return;
    }

    setState(() {
      _nombre  = datos.nombre;
      _rol     = datos.rol;
      _nivel   = datos.nivel;
      _inicial = datos.inicial;
    });
  }

  Future<void> _cerrarSesion() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await PerfilService.cerrarSesion();
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: const RouteSettings(name: '/'),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = MyApp.of(context).currentTheme;
    final isDark = globalTheme == ThemeMode.system
        ? MediaQuery.of(context).platformBrightness == Brightness.dark
        : globalTheme == ThemeMode.dark;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text(
          'Perfil y ajustes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? sw * 0.03 : 20,
          vertical: 8,
        ),
        child: isWide
            ? _buildWideLayout(isDark, sw)
            : _buildNarrowLayout(isDark),
      ),
    );
  }

  Widget _buildWideLayout(bool isDark, double sw) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: sw * 0.25, child: _avatarSection(isDark)),
        const SizedBox(width: 32),
        Expanded(child: _settingsSections(isDark)),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatarSection(isDark),
        const SizedBox(height: 28),
        _settingsSections(isDark),
      ],
    );
  }

  Widget _avatarSection(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PerfilDetalleScreen()),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
                  child: Text(
                    _inicial,
                    style: const TextStyle(
                      color: AppColors.primario,
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                    ),
                  ),
                ),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const EditarPerfilDialog(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.secundario,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 25, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(_nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
              '$_rol • Nivel $_nivel',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<DatosRacha>(
              stream: RachaService.streamRacha(),
              builder: (context, snapRacha) {
                final racha = snapRacha.data?.rachaActual ?? 0;
                return StreamBuilder<DatosInsignias>(
                  stream: InsigniasService.streamDatos(),
                  builder: (context, snapInsignias) {
                    final insignias = snapInsignias.data?.totalDesbloqueadas ?? 0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BadgeLabel(
                          icon: Icons.local_fire_department,
                          label: '$racha Días Racha',
                          color: AppColors.naranja1,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RachaDiariaScreen()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BadgeLabel(
                          icon: Icons.emoji_events_outlined,
                          label: '$insignias Insignias',
                          color: AppColors.amarillo1,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PerfilDetalleScreen()),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsSections(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── GENERAL ──────────────────────────────────────────────────
        SeccionLabel(label: 'GENERAL'),
        const SizedBox(height: 8),
        GrupoAjustes(isDark: isDark, items: [
          ItemAjuste(
            icono: Icons.school_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Preferencias de aprendizaje',
            subtitulo: 'Metas diarias, recordatorios',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const PreferenciasDialog(),
            ),
          ),
          ItemAjuste(
            icono: Icons.notifications_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Notificaciones',
            subtitulo: 'Push, correo electrónico',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const NotificacionesDialog(),
            ),
          ),
          ItemAjuste(
            icono: Icons.language_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Idioma de interfaz',
            subtitulo: 'Español (México)',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const IdiomaDialog(),
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── APARIENCIA ────────────────────────────────────────────────
        SeccionLabel(label: 'APARIENCIA'),
        const SizedBox(height: 8),
        GrupoAjustes(isDark: isDark, items: [
          ItemAjuste(
            icono: Icons.dark_mode_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Modo Oscuro',
            trailing: Switch(
              value: isDark,
              onChanged: (v) => MyApp.of(context).toggleTheme(v),
              activeThumbColor: AppColors.secundario,
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── CUENTA ────────────────────────────────────────────────────
        SeccionLabel(label: 'CUENTA'),
        const SizedBox(height: 8),
        GrupoAjustes(isDark: isDark, items: [
          ItemAjuste(
            icono: Icons.security_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Privacidad y Seguridad',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const PrivacidadSeguridadDialog(),
            ),
          ),
        ]),
        const SizedBox(height: 8),

        // ── Cerrar sesión ─────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.rojo1.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.logout, color: AppColors.rojo1, size: 18),
            ),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: AppColors.rojo1,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            onTap: _cerrarSesion,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Tepetl v2.4.0 (Build 342)',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
