import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tepetl/app.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

EdgeInsets _dialogInsetPadding(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w > 700) {
    final hPad = w * 0.20; // 20% cada lado → diálogo ocupa 60% del ancho
    return EdgeInsets.symmetric(horizontal: hPad, vertical: 24);
  }
  return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
}

class PerfilAjustesScreen extends StatefulWidget {
  final ThemeMode? currentThemeMode;

  const PerfilAjustesScreen({
    super.key,
    this.currentThemeMode,
  });

  @override
  State<PerfilAjustesScreen> createState() => _PerfilAjustesScreenState();
}

class _PerfilAjustesScreenState extends State<PerfilAjustesScreen> {
  String _nombre = 'Cargando...';
  String _rol = '';
  String _nivel = '';
  String _inicial = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          
          setState(() {
            // Asigna el nombre
            _nombre = data['nombre'] ?? 'Usuario';
            
            // Asigna y capitaliza la primera letra del rol (ej: "estudiante" -> "Estudiante")
            String rolCrudo = data['rol'] ?? 'Estudiante';
            if (rolCrudo.isNotEmpty) {
              _rol = rolCrudo[0].toUpperCase() + rolCrudo.substring(1);
            }
            
            // Asigna el nivel (si guardas algo como "basico", puedes formatearlo aquí)
            _nivel = data['nivel'] ?? '1'; 
            if (_nivel == 'basico') _nivel = 'Básico';
            if (_nivel == 'intermedio') _nivel = 'Intermedio';

            // Toma la primera letra del nombre para el avatar
            _inicial = _nombre.isNotEmpty ? _nombre[0].toUpperCase() : 'U';
          });
        }
      } catch (e) {
        print('❌ Error al cargar datos del perfil: $e');
      }
    } else {
      // 👇 SI EL USUARIO ES NULL (Ej. recargó la página sin sesión) 👇
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: '/'),
          ),
          (route) => false,
        );
      }
    }
  }

  void _abrirPerfil() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const PerfilDetalleScreen()));

  // ── Preferencias de aprendizaje ──────────────────────────────────────────
  void _abrirPreferencias() {
    showDialog(
      context: context,
      builder: (_) => const _PreferenciasDialog(),
    );
  }

  // ── Notificaciones ───────────────────────────────────────────────────────
  void _abrirNotificaciones() {
    showDialog(
      context: context,
      builder: (_) => const _NotificacionesDialog(),
    );
  }

  // ── Idioma ───────────────────────────────────────────────────────────────
  void _abrirIdioma() {
    showDialog(
      context: context,
      builder: (_) => const _IdiomaDialog(),
    );
  }

  // ── Privacidad y Seguridad ───────────────────────────────────────────────
  void _abrirPrivacidad() {
    showDialog(
      context: context,
      builder: (_) => const _PrivacidadSeguridad(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = MyApp.of(context).currentTheme;
    bool isDarkMode;
    
    if (globalTheme == ThemeMode.system) {
      // Si está en automático, preguntamos al sistema operativo
      isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else {
      // Si el usuario eligió uno fijo, usamos ese
      isDarkMode = globalTheme == ThemeMode.dark;
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.fondoOscuro : Colors.white,
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
          horizontal: isWide ? screenWidth * 0.03 : 20, // era 0.1
          vertical: 8,
        ),
        child: isWide
            ? _buildWideLayout(isDarkMode, screenWidth)
            : _buildNarrowLayout(isDarkMode),
      ),
    );
  }

  // ── Layout ancho (desktop) ───────────────────────────────────────────────
  Widget _buildWideLayout(bool isDarkMode, double screenWidth) {
    // La columna izquierda ocupa ~28% del ancho disponible (era fija en 260)
    final leftWidth = screenWidth * 0.25;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: avatar + nombre + badges
        SizedBox(
          width: leftWidth,
          child: _buildAvatarSection(isDarkMode),
        ),
        const SizedBox(width: 32),
        // Columna derecha: ajustes
        Expanded(child: _buildSettingsSections(isDarkMode)),
      ],
    );
  }

  // ── Layout estrecho (móvil) ──────────────────────────────────────────────
  Widget _buildNarrowLayout(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatarSection(isDarkMode),
        const SizedBox(height: 28),
        _buildSettingsSections(isDarkMode),
      ],
    );
  }

  Widget _buildAvatarSection(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _abrirPerfil,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isDark
                      ? AppColors.fondoOscuroSecundario
                      : AppColors.fondoSecundario,
                  child: Text(
                    _inicial,
                    style: TextStyle(
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
                    onTap: () => _abrirEdicionPerfil(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.secundario,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _nombre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '$_rol • Nivel $_nivel',
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Badge(
                  icon: Icons.local_fire_department,
                  label: '14 Días Racha',
                  color: AppColors.naranja1,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RachaDiariaScreen())),
                ),
                const SizedBox(width: 8),
                _Badge(
                  icon: Icons.emoji_events_outlined,
                  label: '10 Insignias',
                  color: AppColors.amarillo1,
                  onTap: _abrirPerfil,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSections(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── GENERAL ──────────────────────────────────────────────
        _SeccionLabel(label: 'GENERAL', isDark: isDarkMode),
        const SizedBox(height: 8),
        _GrupoAjustes(isDark: isDarkMode, items: [
          _ItemAjuste(
            icono: Icons.school_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Preferencias de aprendizaje',
            subtitulo: 'Metas diarias, recordatorios',
            onTap: _abrirPreferencias,
          ),
          _ItemAjuste(
            icono: Icons.notifications_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Notificaciones',
            subtitulo: 'Push, correo electrónico',
            onTap: _abrirNotificaciones,
          ),
          _ItemAjuste(
            icono: Icons.language_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Idioma de interfaz',
            subtitulo: 'Español (México)',
            onTap: _abrirIdioma,
          ),
        ]),
        const SizedBox(height: 20),

        // ── APARIENCIA ────────────────────────────────────────────
        _SeccionLabel(label: 'APARIENCIA', isDark: isDarkMode),
        const SizedBox(height: 8),
        _GrupoAjustes(isDark: isDarkMode, items: [
          _ItemAjuste(
            icono: Icons.dark_mode_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Modo Oscuro',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (bool newValue) {
                // Mandamos la orden al controlador global
                MyApp.of(context).toggleTheme(newValue);
              },
              activeThumbColor: AppColors.secundario,
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── CUENTA ───────────────────────────────────────────────
        _SeccionLabel(label: 'CUENTA', isDark: isDarkMode),
        const SizedBox(height: 8),
        _GrupoAjustes(isDark: isDarkMode, items: [
          _ItemAjuste(
            icono: Icons.security_outlined,
            iconColor: AppColors.secundario,
            titulo: 'Privacidad y Seguridad',
            onTap: _abrirPrivacidad,
          ),
        ]),
        const SizedBox(height: 8),
        // Cerrar sesión
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.fondoOscuroSecundario
                : AppColors.fondoSecundario,
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
                  fontSize: 14),
            ),
            onTap: () async {
              // Mostramos un mini diálogo de carga por si tarda
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                await FirebaseAuth.instance.signOut();
              
                if (context.mounted) Navigator.pop(context);

                // 2. Mandamos al usuario a la pantalla de Login y borramos el historial
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(), 
                      settings: const RouteSettings(name: '/'),
                    ),
                    (route) => false, // Elimina las pantallas previas
                  );
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context); // Quitamos la carga
                // Mostramos un error si falla
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cerrar sesión: $e')),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Tepetl v2.4.0 (Build 342)',
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Abre el diálogo de edición de perfil (lápiz) ─────────────────────────
  void _abrirEdicionPerfil(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _EditarPerfilDialog(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIÁLOGO — Editar Perfil (imagen + nombre)
// ═══════════════════════════════════════════════════════════════════════════════

class _EditarPerfilDialog extends StatefulWidget {
  const _EditarPerfilDialog();

  @override
  State<_EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<_EditarPerfilDialog> {
  final _nombreCtrl = TextEditingController(text: 'Alex Alex Alex');
  final _apodoCtrl = TextEditingController(text: 'Aprendiz Intermedio');
  String? _imagenSeleccionada;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apodoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Editar Perfil',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 20),
              // Avatar con botón de cámara
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: isDark
                        ? AppColors.fondoOscuro
                        : AppColors.fondoSecundario,
                    backgroundImage: _imagenSeleccionada != null
                        ? NetworkImage(_imagenSeleccionada!)
                        : null,
                    child: _imagenSeleccionada == null
                        ? const Text('G',
                            style: TextStyle(
                                color: AppColors.primario,
                                fontWeight: FontWeight.bold,
                                fontSize: 32))
                        : null,
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: GestureDetector(
                      onTap: _seleccionarImagen,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AppColors.secundario,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _seleccionarImagen,
                child: Text('Cambiar foto de perfil',
                    style: TextStyle(
                        color: AppColors.secundario,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                  label: 'Nombre completo',
                  controller: _nombreCtrl,
                  isDark: isDark),
              const SizedBox(height: 12),
              _CampoTexto(
                  label: 'Apodo / Nivel',
                  controller: _apodoCtrl,
                  isDark: isDark),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.secundario.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí se guardarían los cambios
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Perfil actualizado'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secundario,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _seleccionarImagen() {
    // En producción se usaría image_picker. Mostramos un snackbar informativo.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Conecta image_picker para seleccionar fotos del dispositivo.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIÁLOGO — Preferencias de aprendizaje
// ═══════════════════════════════════════════════════════════════════════════════

class _PreferenciasDialog extends StatefulWidget {
  const _PreferenciasDialog();

  @override
  State<_PreferenciasDialog> createState() => _PreferenciasDialogState();
}

class _PreferenciasDialogState extends State<_PreferenciasDialog> {
  double _metaDiaria = 20; // minutos
  bool _recordatorio = true;
  TimeOfDay _horaRecordatorio = const TimeOfDay(hour: 8, minute: 0);
  String _nivelObjetivo = 'Intermedio';

  static const _niveles = ['Principiante', 'Intermedio', 'Avanzado', 'Experto'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogTitle(
                  title: 'Preferencias de aprendizaje', icon: Icons.school_outlined),
              const SizedBox(height: 20),
              Text('Meta diaria: ${_metaDiaria.toInt()} min',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              Slider(
                value: _metaDiaria,
                min: 5,
                max: 60,
                divisions: 11,
                activeColor: AppColors.secundario,
                label: '${_metaDiaria.toInt()} min',
                onChanged: (v) => setState(() => _metaDiaria = v),
              ),
              const SizedBox(height: 12),
              Text('Nivel objetivo',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _niveles.map((n) {
                  final sel = n == _nivelObjetivo;
                  return ChoiceChip(
                    label: Text(n),
                    selected: sel,
                    onSelected: (_) => setState(() => _nivelObjetivo = n),
                    selectedColor: AppColors.secundario,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : null,
                        fontWeight: FontWeight.w600),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recordatorio diario',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Switch(
                    value: _recordatorio,
                    activeColor: AppColors.secundario,
                    onChanged: (v) => setState(() => _recordatorio = v),
                  ),
                ],
              ),
              if (_recordatorio) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final t = await showTimePicker(
                        context: context, initialTime: _horaRecordatorio);
                    if (t != null) setState(() => _horaRecordatorio = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secundario.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.secundario.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: AppColors.secundario, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _horaRecordatorio.format(context),
                          style: const TextStyle(
                              color: AppColors.secundario,
                              fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right,
                            color: AppColors.secundario.withValues(alpha: 0.6),
                            size: 18),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _DialogActions(onGuardar: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIÁLOGO — Notificaciones
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificacionesDialog extends StatefulWidget {
  const _NotificacionesDialog();

  @override
  State<_NotificacionesDialog> createState() => _NotificacionesDialogState();
}

class _NotificacionesDialogState extends State<_NotificacionesDialog> {
  bool _push = true;
  bool _correo = false;
  bool _racha = true;
  bool _logros = true;
  bool _retosSemanales = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogTitle(
                title: 'Notificaciones', icon: Icons.notifications_outlined),
            const SizedBox(height: 20),
            _SwitchRow(
                label: 'Notificaciones Push',
                sub: 'Alertas en tu dispositivo',
                value: _push,
                onChanged: (v) => setState(() => _push = v)),
            _SwitchRow(
                label: 'Correo electrónico',
                sub: 'Resúmenes y novedades',
                value: _correo,
                onChanged: (v) => setState(() => _correo = v)),
            const Divider(height: 24),
            Text('Tipos de alertas',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            _SwitchRow(
                label: 'Racha diaria',
                value: _racha,
                onChanged: (v) => setState(() => _racha = v)),
            _SwitchRow(
                label: 'Logros e insignias',
                value: _logros,
                onChanged: (v) => setState(() => _logros = v)),
            _SwitchRow(
                label: 'Retos semanales',
                value: _retosSemanales,
                onChanged: (v) => setState(() => _retosSemanales = v)),
            const SizedBox(height: 20),
            _DialogActions(onGuardar: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIÁLOGO — Idioma de interfaz
// ═══════════════════════════════════════════════════════════════════════════════

class _IdiomaDialog extends StatefulWidget {
  const _IdiomaDialog();

  @override
  State<_IdiomaDialog> createState() => _IdiomaDialogState();
}

class _IdiomaDialogState extends State<_IdiomaDialog> {
  String _seleccionado = 'Español (México)';

  static const _idiomas = [
    ('🇲🇽', 'Español (México)'),
    ('🇪🇸', 'Español (España)'),
    ('🇺🇸', 'English (US)'),
    ('🇬🇧', 'English (UK)'),
    ('🇫🇷', 'Français'),
    ('🇩🇪', 'Deutsch'),
    ('🇧🇷', 'Português (BR)'),
    ('🇯🇵', '日本語'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogTitle(
                title: 'Idioma de interfaz', icon: Icons.language_outlined),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _idiomas.length,
                itemBuilder: (_, i) {
                  final (flag, nombre) = _idiomas[i];
                  final sel = nombre == _seleccionado;
                  return ListTile(
                    leading: Text(flag, style: const TextStyle(fontSize: 22)),
                    title: Text(nombre,
                        style: TextStyle(
                            fontWeight: sel
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: sel
                                ? AppColors.secundario
                                : Theme.of(context).colorScheme.onSurface)),
                    trailing: sel
                        ? const Icon(Icons.check_circle,
                            color: AppColors.secundario)
                        : null,
                    onTap: () => setState(() => _seleccionado = nombre),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _DialogActions(onGuardar: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIÁLOGO — Privacidad y Seguridad
// ═══════════════════════════════════════════════════════════════════════════════

class _PrivacidadSeguridad extends StatelessWidget {
  const _PrivacidadSeguridad();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogTitle(
                title: 'Privacidad y Seguridad',
                icon: Icons.security_outlined),
            const SizedBox(height: 16),
            _OpcionSeguridad(
              icono: Icons.lock_outline,
              titulo: 'Cambiar contraseña',
              sub: 'Actualiza tu contraseña de acceso',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (_) => const _CambiarContrasenaDialog());
              },
            ),
            _OpcionSeguridad(
              icono: Icons.email_outlined,
              titulo: 'Cambiar correo electrónico',
              sub: 'alex@correo.com',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (_) => const _CambiarCorreoDialog());
              },
            ),
            _OpcionSeguridad(
              icono: Icons.phone_outlined,
              titulo: 'Número de teléfono',
              sub: 'Agrega un número de recuperación',
              onTap: () {},
            ),
            _OpcionSeguridad(
              icono: Icons.verified_user_outlined,
              titulo: 'Autenticación en dos pasos',
              sub: 'Aumenta la seguridad de tu cuenta',
              onTap: () {},
            ),
            _OpcionSeguridad(
              icono: Icons.delete_outline,
              titulo: 'Eliminar cuenta',
              sub: 'Esta acción es irreversible',
              color: AppColors.rojo1,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cambiar contraseña ────────────────────────────────────────────────────────

class _CambiarContrasenaDialog extends StatefulWidget {
  const _CambiarContrasenaDialog();

  @override
  State<_CambiarContrasenaDialog> createState() =>
      _CambiarContrasenaDialogState();
}

class _CambiarContrasenaDialogState extends State<_CambiarContrasenaDialog> {
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _verActual = false;
  bool _verNueva = false;
  bool _verConfirmar = false;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogTitle(
                title: 'Cambiar contraseña', icon: Icons.lock_outline),
            const SizedBox(height: 20),
            _CampoPassword(
                label: 'Contraseña actual',
                controller: _actualCtrl,
                isDark: isDark,
                visible: _verActual,
                onToggle: () => setState(() => _verActual = !_verActual)),
            const SizedBox(height: 12),
            _CampoPassword(
                label: 'Nueva contraseña',
                controller: _nuevaCtrl,
                isDark: isDark,
                visible: _verNueva,
                onToggle: () => setState(() => _verNueva = !_verNueva)),
            const SizedBox(height: 12),
            _CampoPassword(
                label: 'Confirmar contraseña',
                controller: _confirmarCtrl,
                isDark: isDark,
                visible: _verConfirmar,
                onToggle: () =>
                    setState(() => _verConfirmar = !_verConfirmar)),
            const SizedBox(height: 24),
            _DialogActions(onGuardar: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Contraseña actualizada correctamente')));
            }),
          ],
        ),
      ),
    );
  }
}

// ── Cambiar correo ────────────────────────────────────────────────────────────

class _CambiarCorreoDialog extends StatefulWidget {
  const _CambiarCorreoDialog();

  @override
  State<_CambiarCorreoDialog> createState() => _CambiarCorreoDialogState();
}

class _CambiarCorreoDialogState extends State<_CambiarCorreoDialog> {
  final _correoCtrl =
      TextEditingController(text: 'alex@correo.com');
  final _passCtrl = TextEditingController();
  bool _verPass = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: _dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogTitle(
                title: 'Cambiar correo electrónico',
                icon: Icons.email_outlined),
            const SizedBox(height: 20),
            _CampoTexto(
                label: 'Nuevo correo electrónico',
                controller: _correoCtrl,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _CampoPassword(
                label: 'Contraseña actual (para confirmar)',
                controller: _passCtrl,
                isDark: isDark,
                visible: _verPass,
                onToggle: () => setState(() => _verPass = !_verPass)),
            const SizedBox(height: 6),
            Text(
              'Te enviaremos un correo de verificación a la nueva dirección.',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 24),
            _DialogActions(onGuardar: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Correo de verificación enviado')));
            }),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PANTALLA 2 — Perfil Detalle (se abre al tocar el avatar / nombre)
// ═══════════════════════════════════════════════════════════════════════════════

class PerfilDetalleScreen extends StatelessWidget {
  const PerfilDetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? screenWidth * 0.03 : 20, // era 0.08
          vertical: 12,
        ),
        child: isWide
            ? _buildWideLayout(context, isDark, screenWidth)
            : _buildNarrowLayout(context, isDark),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isDark, double screenWidth) {
    // La columna izquierda ocupa ~28% del ancho disponible (era fija en 280)
    final leftWidth = screenWidth * 0.28;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: avatar + stats + insignias
        SizedBox(
          width: leftWidth,
          child: _buildLeftColumn(context, isDark),
        ),
        const SizedBox(width: 32),
        // Columna derecha: camino de insignias + reto
        Expanded(
          child: _buildRightColumn(context, isDark),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildLeftColumn(context, isDark).children,
        const SizedBox(height: 24),
        ..._buildRightColumn(context, isDark).children,
      ],
    );
  }

  Column _buildLeftColumn(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Avatar + nombre ────────────────────────────────────
        Center(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isDark
                        ? AppColors.fondoOscuroSecundario
                        : AppColors.fondoSecundario,
                    child: const Text('A',
                        style: TextStyle(
                            color: AppColors.primario,
                            fontWeight: FontWeight.bold,
                            fontSize: 30)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Alex',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('GUERRERO',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secundario,
                      letterSpacing: 1.0)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // ── Estadísticas ───────────────────────────────────────
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icono: Icons.star_outline,
                iconColor: AppColors.azul1,
                label: 'Palabras nuevas',
                valor: '150',
                delta: '+14%',
                deltaColor: AppColors.secundario,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icono: Icons.local_fire_department,
                iconColor: AppColors.naranja1,
                label: 'Racha',
                valor: '12',
                delta: 'Días',
                deltaColor: AppColors.naranja1,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icono: Icons.diamond_outlined,
                iconColor: AppColors.verde1,
                label: 'Jade',
                valor: '2.4k',
                delta: '+600',
                deltaColor: AppColors.secundario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // ── Insignias ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Insignias',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface)),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InsigniasScreen())),
              child: Text('Ver todos',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secundario)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _InsigniaCirculo(
                emoji: '☀️', label: 'Piedra Solar', desbloqueada: true),
            const SizedBox(width: 12),
            _InsigniaCirculo(
                emoji: '💧', label: 'Gota de Agua', desbloqueada: true),
            const SizedBox(width: 12),
            _InsigniaCirculo(
                emoji: '🌿', label: 'Hoja de Árbol', desbloqueada: true),
          ],
        ),
      ],
    );
  }

  Column _buildRightColumn(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Camino de insignias ──────────────────────────────
        Text('Camino de insignias',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 16),
        _CaminoInsignias(isDark: isDark),
        const SizedBox(height: 24),
        // ── Reto semanal ─────────────────────────────────────
        _RetoSemanal(isDark: isDark),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PANTALLA 3 — Racha Diaria
// ═══════════════════════════════════════════════════════════════════════════════

class RachaDiariaScreen extends StatelessWidget {
  const RachaDiariaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semana = [true, true, true, true, false, false, false];
    const hoyIndex = 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text('Racha diaria',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? screenWidth * 0.03 : 24, // era 0.05
          vertical: 8,
        ),
        child: isWide
            ? _buildWideLayout(context, isDark, semana, hoyIndex)
            : _buildNarrowLayout(context, isDark, semana, hoyIndex),
      ),
    );
  }

  Widget _buildWideLayout(
      BuildContext context, bool isDark, List<bool> semana, int hoyIndex) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Izquierda: sol + mensaje + días + botón
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _SolRacha(dias: 14, isDark: isDark),
              const SizedBox(height: 28),
              Text(
                '¡Tu fuego interno brilla con fuerza!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Has estudiado náhuatl por 12 días seguidos.\nTonatiuh te sonríe hoy.',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.75),
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _DiasSemanales(
                  dias: semana, hoyIndex: hoyIndex, isDark: isDark),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_fire_department, size: 18),
                  label: const Text('Mantener el Fuego',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amarillo1,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              // Estadísticas extra en wide
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icono: Icons.emoji_events_outlined,
                      iconColor: AppColors.amarillo1,
                      label: 'Mejor racha',
                      valor: '28',
                      delta: 'Días',
                      deltaColor: AppColors.amarillo1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icono: Icons.menu_book_outlined,
                      iconColor: AppColors.azul1,
                      label: 'Total lecciones',
                      valor: '154',
                      delta: 'Completadas',
                      deltaColor: AppColors.azul1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Derecha: calendario + protector
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _CalendarioRacha(isDark: isDark),
              const SizedBox(height: 24),
              _ProtectorRacha(isDark: isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
      BuildContext context, bool isDark, List<bool> semana, int hoyIndex) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _SolRacha(dias: 14, isDark: isDark),
        const SizedBox(height: 28),
        Text(
          '¡Tu fuego interno brilla con fuerza!',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Has estudiado náhuatl por 12 días seguidos.\nTonatiuh te sonríe hoy.',
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.75),
              height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _DiasSemanales(dias: semana, hoyIndex: hoyIndex, isDark: isDark),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.local_fire_department, size: 18),
            label: const Text('Mantener el Fuego',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amarillo1,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _CalendarioRacha(isDark: isDark),
        const SizedBox(height: 24),
        _ProtectorRacha(isDark: isDark),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PANTALLA 4 — Tus Insignias
// ═══════════════════════════════════════════════════════════════════════════════

class InsigniasScreen extends StatelessWidget {
  const InsigniasScreen({super.key});

  static const List<_Insignia> _insignias = [
    _Insignia(emoji: '☀️', label: 'Piedra Solar', desbloqueada: true),
    _Insignia(emoji: '💧', label: 'Piedra Solar', desbloqueada: true),
    _Insignia(emoji: '🌿', label: 'Piedra Solar', desbloqueada: true),
    _Insignia(emoji: '🛡️', label: 'Escudo de Guerra', desbloqueada: false),
    _Insignia(emoji: '📝', label: 'Teje Palabras', desbloqueada: false),
    _Insignia(emoji: '🏛️', label: 'Guardián Templo', desbloqueada: false),
    _Insignia(emoji: '🦅', label: 'Guerrero Águila', desbloqueada: false),
    _Insignia(emoji: '🦋', label: 'Volador Nato', desbloqueada: false),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;
    final crossAxisCount = isWide ? 4 : 3;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text('Tus Insignias',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? screenWidth * 0.03 : 20, // era 0.1
          vertical: 16,
        ),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Izquierda: insignia destacada + progreso
                  // Ancho proporcional al 22% de la pantalla (era fijo en 260)
                  SizedBox(
                    width: screenWidth * 0.22,
                    child: _buildLeftPanel(context, isDark),
                  ),
                  const SizedBox(width: 32),
                  // Derecha: grid
                  Expanded(
                    child: _buildGrid(isDark, crossAxisCount),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildLeftPanel(context, isDark),
                  const SizedBox(height: 28),
                  _buildGrid(isDark, crossAxisCount),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secundario,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: const Center(
              child: Text('☀️', style: TextStyle(fontSize: 36))),
        ),
        const SizedBox(height: 20),
        Text(
          'Explora tus medallas obtenidas',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '10 de 100 desbloqueados',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.75)),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.1,
            minHeight: 6,
            backgroundColor: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.secundario),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(bool isDark, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _insignias.length,
      itemBuilder: (_, i) =>
          _GridInsignia(insignia: _insignias[i], isDark: isDark),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS COMPARTIDOS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Sección label ─────────────────────────────────────────────────────────────

class _SeccionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SeccionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.7),
      ),
    );
  }
}

// ── Grupo de ajustes ──────────────────────────────────────────────────────────

class _GrupoAjustes extends StatelessWidget {
  final bool isDark;
  final List<_ItemAjuste> items;
  const _GrupoAjustes({required this.isDark, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3)),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.1)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Item de ajuste ────────────────────────────────────────────────────────────

class _ItemAjuste extends StatelessWidget {
  final IconData icono;
  final Color iconColor;
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ItemAjuste({
    required this.icono,
    required this.iconColor,
    required this.titulo,
    this.subtitulo,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icono, color: iconColor, size: 18),
      ),
      title: Text(titulo,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      subtitle: subtitulo != null
          ? Text(subtitulo!,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.75)))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.75),
                  size: 20)
              : null),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icono;
  final Color iconColor;
  final String label;
  final String valor;
  final String delta;
  final Color deltaColor;

  const _StatCard({
    required this.icono,
    required this.iconColor,
    required this.label,
    required this.valor,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface)),
          Text(delta,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: deltaColor)),
        ],
      ),
    );
  }
}

// ── Insignia Circulo (perfil detalle) ─────────────────────────────────────────

class _InsigniaCirculo extends StatelessWidget {
  final String emoji;
  final String label;
  final bool desbloqueada;

  const _InsigniaCirculo({
    required this.emoji,
    required this.label,
    required this.desbloqueada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: desbloqueada
                ? AppColors.secundario.withValues(alpha: 0.2)
                : (Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.2)),
            shape: BoxShape.circle,
            border: Border.all(
              color: desbloqueada
                  ? AppColors.secundario.withValues(alpha: 0.3)
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: desbloqueada
                ? Text(emoji, style: const TextStyle(fontSize: 26))
                : Icon(Icons.lock_outline,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.75),
                    size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.75))),
      ],
    );
  }
}

// ── Camino de Insignias ───────────────────────────────────────────────────────

class _CaminoInsignias extends StatelessWidget {
  final bool isDark;
  const _CaminoInsignias({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final etapas = [
      _Etapa(
          nombre: 'Fuego Maestro',
          nivel: 'EXPERTO',
          nivelColor: AppColors.azul1,
          desc: 'Master fluency and complex metaphors.',
          completada: false,
          activa: false),
      _Etapa(
          nombre: 'Espada de Jade',
          nivel: 'AVANZADO',
          nivelColor: AppColors.azul1,
          desc: 'Conversational skills and storytelling.',
          completada: false,
          activa: false),
      _Etapa(
          nombre: 'Escudo de Guerra',
          nivel: '30%',
          nivelColor: AppColors.secundario,
          desc:
              'Domique las conjugaciones verbales y estructura oracional.',
          completada: false,
          activa: true,
          xp: '430/1000 XP'),
      _Etapa(
          nombre: 'Piedra Solar',
          nivel: 'COMPLETADO',
          nivelColor: AppColors.secundario,
          desc: 'Conceptos básicos, saludos y sustantivos comunes.',
          completada: true,
          activa: false),
    ];

    return Column(
      children: etapas.asMap().entries.map((e) {
        final isLast = e.key == etapas.length - 1;
        return _FilaEtapa(etapa: e.value, isDark: isDark, isLast: isLast);
      }).toList(),
    );
  }
}

class _Etapa {
  final String nombre;
  final String nivel;
  final Color nivelColor;
  final String desc;
  final bool completada;
  final bool activa;
  final String? xp;

  const _Etapa({
    required this.nombre,
    required this.nivel,
    required this.nivelColor,
    required this.desc,
    required this.completada,
    required this.activa,
    this.xp,
  });
}

class _FilaEtapa extends StatelessWidget {
  final _Etapa etapa;
  final bool isDark;
  final bool isLast;
  const _FilaEtapa(
      {required this.etapa, required this.isDark, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: etapa.completada || etapa.activa
                        ? AppColors.secundario
                        : (Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.3)),
                    shape: BoxShape.circle,
                    border: etapa.activa
                        ? Border.all(color: AppColors.secundario, width: 3)
                        : null,
                  ),
                  child: etapa.completada
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                        width: 2,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.3)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: etapa.activa
                  ? Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.secundario.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                AppColors.secundario.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(etapa.nombre,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.85))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secundario,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(etapa.nivel,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(etapa.desc,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.75),
                                  height: 1.4)),
                          if (etapa.xp != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(etapa.xp!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secundario)),
                                Text('Week ly',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.75))),
                              ],
                            ),
                          ],
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(etapa.nombre,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.85))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    etapa.nivelColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(etapa.nivel,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: etapa.nivelColor,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(etapa.desc,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.75),
                                height: 1.4)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reto Semanal ──────────────────────────────────────────────────────────────

class _RetoSemanal extends StatelessWidget {
  final bool isDark;
  const _RetoSemanal({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secundario.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.secundario.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reto Semanal',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.85))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.naranja1.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Esta semana',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.naranja1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completa 5 lecciones de "Comida y Mercado" para ganar el escudo Azteca.',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.75),
                height: 1.4),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.4,
              minHeight: 7,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.secundario),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sol de racha ──────────────────────────────────────────────────────────────

class _SolRacha extends StatelessWidget {
  final int dias;
  final bool isDark;
  const _SolRacha({required this.dias, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _SolPainter(),
        child: Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppColors.amarillo1,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 22),
                Text(
                  '$dias',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'DÍAS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintAmarillo = Paint()
      ..color = AppColors.amarillo1
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final paintGris = Paint()
      ..color = AppColors.textoSecundario40
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const rayos = 12;
    const innerR = 68.0;
    const outerR = 88.0;

    for (int i = 0; i < rayos; i++) {
      final angle = (i * 2 * math.pi) / rayos - math.pi / 2;
      final start = Offset(center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle));
      final end = Offset(center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle));
      canvas.drawLine(start, end, i < 8 ? paintAmarillo : paintGris);
    }
  }

  @override
  bool shouldRepaint(_SolPainter old) => false;
}

// ── Días semanales ────────────────────────────────────────────────────────────

class _DiasSemanales extends StatelessWidget {
  final List<bool> dias;
  final int hoyIndex;
  final bool isDark;

  const _DiasSemanales({
    required this.dias,
    required this.hoyIndex,
    required this.isDark,
  });

  static const _labels = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final completado = dias[i];
        final esHoy = i == hoyIndex;

        return Column(
          children: [
            if (esHoy)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secundario,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Hoy',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              )
            else
              const SizedBox(height: 18),
            const SizedBox(height: 4),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: completado
                    ? AppColors.secundario
                    : esHoy
                        ? AppColors.amarillo1.withValues(alpha: 0.2)
                        : (Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.2)),
                shape: BoxShape.circle,
                border: esHoy && !completado
                    ? Border.all(color: AppColors.amarillo1, width: 2)
                    : null,
              ),
              child: Icon(
                completado ? Icons.check : Icons.local_fire_department,
                size: 16,
                color: completado || esHoy
                    ? Colors.white
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 6),
            Text(_labels[i],
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.65))),
          ],
        );
      }),
    );
  }
}

// ── Calendario de racha ───────────────────────────────────────────────────────

class _CalendarioRacha extends StatelessWidget {
  final bool isDark;
  const _CalendarioRacha({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final diasConRacha = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13};
    const hoy = 14;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(3, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Marzo 2026',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant)),
              Row(
                children: [
                  Icon(Icons.chevron_left,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                      size: 20),
                  Icon(Icons.chevron_right,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                      size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                .map((d) => SizedBox(
                      width: 32,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.75))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          _GridCalendario(
              diasConRacha: diasConRacha,
              hoy: hoy,
              totalDias: 31,
              primerDia: 0,
              isDark: isDark),
        ],
      ),
    );
  }
}

class _GridCalendario extends StatelessWidget {
  final Set<int> diasConRacha;
  final int hoy;
  final int totalDias;
  final int primerDia;
  final bool isDark;

  const _GridCalendario({
    required this.diasConRacha,
    required this.hoy,
    required this.totalDias,
    required this.primerDia,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final celdas = primerDia + totalDias;
    final filas = (celdas / 7).ceil();

    return Column(
      children: List.generate(filas, (fila) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (col) {
            final idx = fila * 7 + col;
            final dia = idx - primerDia + 1;
            if (dia < 1 || dia > totalDias) {
              return const SizedBox(width: 32, height: 32);
            }
            final tieneRacha = diasConRacha.contains(dia);
            final esHoy = dia == hoy;

            return Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: esHoy ? AppColors.amarillo1 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: tieneRacha && !esHoy
                    ? const Text('★',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.amarillo1))
                    : Text(
                        '$dia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              esHoy ? FontWeight.w900 : FontWeight.w500,
                          color: esHoy
                              ? Colors.white
                              : (Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.65)),
                        ),
                      ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ── Protector de racha ────────────────────────────────────────────────────────

class _ProtectorRacha extends StatelessWidget {
  final bool isDark;
  const _ProtectorRacha({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.azul1.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.azul1.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined,
                color: AppColors.azul1, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protector de Racha',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 3),
                Text(
                  'Equipado. Tu racha está segura por hoy si olvidas practicar.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.65),
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid Insignia (pantalla insignias) ───────────────────────────────────────

class _Insignia {
  final String emoji;
  final String label;
  final bool desbloqueada;

  const _Insignia({
    required this.emoji,
    required this.label,
    required this.desbloqueada,
  });
}

class _GridInsignia extends StatelessWidget {
  final _Insignia insignia;
  final bool isDark;

  const _GridInsignia({required this.insignia, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: insignia.desbloqueada
                ? AppColors.secundario.withValues(alpha: 0.2)
                : (Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.2)),
            shape: BoxShape.circle,
            border: Border.all(
              color: insignia.desbloqueada
                  ? AppColors.secundario.withValues(alpha: 0.3)
                  : Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: insignia.desbloqueada
                ? Text(insignia.emoji,
                    style: const TextStyle(fontSize: 30))
                : Icon(Icons.lock_outline,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                    size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          insignia.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (!insignia.desbloqueada)
          Text(
            'Bloqueado',
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.65)),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES DE DIÁLOGOS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Título de diálogo ─────────────────────────────────────────────────────────

class _DialogTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DialogTitle({required this.title, required this.icon});

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
          child: Icon(icon, color: AppColors.secundario, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

// ── Botones de acción de diálogo ──────────────────────────────────────────────

class _DialogActions extends StatelessWidget {
  final VoidCallback onGuardar;

  const _DialogActions({required this.onGuardar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: AppColors.secundario.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ── Campo de texto genérico ───────────────────────────────────────────────────

class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;
  final TextInputType? keyboardType;

  const _CampoTexto({
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
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6)),
        filled: true,
        fillColor: isDark
            ? AppColors.fondoOscuro
            : AppColors.fondoSecundario,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.secundario, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ── Campo de contraseña ───────────────────────────────────────────────────────

class _CampoPassword extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;
  final bool visible;
  final VoidCallback onToggle;

  const _CampoPassword({
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
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6)),
        filled: true,
        fillColor: isDark
            ? AppColors.fondoOscuro
            : AppColors.fondoSecundario,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.secundario, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(
              visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5)),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ── Switch Row ────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
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
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface)),
                if (sub != null)
                  Text(sub!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55))),
              ],
            ),
          ),
          Switch(
              value: value,
              activeColor: AppColors.secundario,
              onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── Opción de seguridad ───────────────────────────────────────────────────────

class _OpcionSeguridad extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? sub;
  final VoidCallback onTap;
  final Color? color;

  const _OpcionSeguridad({
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
      title: Text(titulo,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: c)),
      subtitle: sub != null
          ? Text(sub!,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)))
          : null,
      trailing: Icon(Icons.chevron_right,
          color: c.withValues(alpha: 0.5), size: 20),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}