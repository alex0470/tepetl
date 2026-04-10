import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PANTALLA 1 — Perfil y Ajustes
// Se abre al tocar el avatar en la AppBar
// ═══════════════════════════════════════════════════════════════════════════════

class PerfilAjustesScreen extends StatefulWidget {
  const PerfilAjustesScreen({super.key});

  @override
  State<PerfilAjustesScreen> createState() => _PerfilAjustesScreenState();
}

class _PerfilAjustesScreenState extends State<PerfilAjustesScreen> {
  bool _modoDoscuro = false;

  void _abrirPerfil() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const PerfilDetalleScreen()));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.fondoOscuro : const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.fondoOscuro : const Color(0xFFF2F4F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text(
          'Perfil y ajustes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + nombre ──────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _abrirPerfil,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: isDark
                              ? AppColors.fondoOscuroSecundario
                              : AppColors.fondoSecundario,
                          child: const Text(
                            'A',
                            style: TextStyle(
                              color: AppColors.primario,
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.naranja1,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Alex Alex Alex',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aprendiz Intermedio • Nivel 12',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 10),
                    // Badges
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
                                  builder: (_) =>
                                      const RachaDiariaScreen())),
                        ),
                        const SizedBox(width: 8),
                        _Badge(
                          icon: Icons.emoji_events_outlined,
                          label: '10 Insignias',
                          color: const Color(0xFFE8A838),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const InsigniasScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── GENERAL ─────────────────────────────────────────────
            _SeccionLabel(label: 'GENERAL', isDark: isDark),
            const SizedBox(height: 8),
            _GrupoAjustes(isDark: isDark, items: [
              _ItemAjuste(
                icono: Icons.school_outlined,
                iconColor: AppColors.secundario,
                titulo: 'Preferencias de aprendizaje',
                subtitulo: 'Metas diarias, recordatorios',
                onTap: () {},
              ),
              _ItemAjuste(
                icono: Icons.notifications_outlined,
                iconColor: AppColors.secundario,
                titulo: 'Notificaciones',
                subtitulo: 'Push, correo electrónico',
                onTap: () {},
              ),
              _ItemAjuste(
                icono: Icons.language_outlined,
                iconColor: AppColors.secundario,
                titulo: 'Idioma de interfaz',
                subtitulo: 'Español (México)',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 20),

            // ── APARIENCIA ───────────────────────────────────────────
            _SeccionLabel(label: 'APARIENCIA', isDark: isDark),
            const SizedBox(height: 8),
            _GrupoAjustes(isDark: isDark, items: [
              _ItemAjuste(
                icono: Icons.dark_mode_outlined,
                iconColor: AppColors.secundario,
                titulo: 'Modo Oscuro',
                trailing: Switch(
                  value: _modoDoscuro,
                  onChanged: (v) => setState(() => _modoDoscuro = v),
                  activeColor: AppColors.secundario,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // ── CUENTA ───────────────────────────────────────────────
            _SeccionLabel(label: 'CUENTA', isDark: isDark),
            const SizedBox(height: 8),
            _GrupoAjustes(isDark: isDark, items: [
              _ItemAjuste(
                icono: Icons.security_outlined,
                iconColor: AppColors.secundario,
                titulo: 'Privacidad y Seguridad',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 8),
            // Cerrar sesión — tarjeta separada
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.logout, color: Colors.redAccent,
                      size: 18),
                ),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Tepetl v2.4.0 (Build 342)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 24),
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.fondoOscuro : const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.fondoOscuro : const Color(0xFFF2F4F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo50.png', width: 22, height: 22,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.terrain, color: AppColors.primario, size: 22)),
            const SizedBox(width: 8),
            const Text(
              'TEPETL',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.primario,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark
                      ? AppColors.fondoOscuroSecundario
                      : AppColors.fondoSecundario,
                  child: const Text('A',
                      style: TextStyle(
                          color: AppColors.primario,
                          fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: AppColors.naranja1, shape: BoxShape.circle),
                    child: const Icon(Icons.local_fire_department,
                        size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + nombre ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: isDark
                            ? AppColors.fondoOscuroSecundario
                            : AppColors.fondoSecundario,
                        child: const Text('A',
                            style: TextStyle(
                                color: AppColors.primario,
                                fontWeight: FontWeight.bold,
                                fontSize: 30)),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              color: AppColors.naranja1,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.local_fire_department,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Alex',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('GUERRERO',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secundario,
                          letterSpacing: 1.0)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Estadísticas ─────────────────────────────────────────
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    icono: Icons.star_outline,
                    iconColor: Color(0xFF5B8DEF),
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
                    iconColor: Color(0xFF5B8DEF),
                    label: 'Jade',
                    valor: '2.4k',
                    delta: '+600',
                    deltaColor: AppColors.secundario,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Insignias ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Insignias',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textoClaro
                            : AppColors.textoSecundario)),
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InsigniasScreen())),
                  child: Text('Ver todos',
                      style: TextStyle(
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
            const SizedBox(height: 24),

            // ── Camino de insignias ──────────────────────────────────
            Text('Camino de insignias',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textoClaro
                        : AppColors.textoSecundario)),
            const SizedBox(height: 16),
            _CaminoInsignias(isDark: isDark),
            const SizedBox(height: 24),

            // ── Reto semanal ─────────────────────────────────────────
            _RetoSemanal(isDark: isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PANTALLA 3 — Racha Diaria
// ═══════════════════════════════════════════════════════════════════════════════

class RachaDiariaScreen extends StatelessWidget {
  const RachaDiariaScreen({super.key});

  static const List<String> _diasCortos = [
    'Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Días completados esta semana (ej: lun-mié completados, jue=hoy)
    final semana = [true, true, true, true, false, false, false];
    final hoyIndex = 3; // Jueves

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.fondoOscuro : const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text('Racha diaria',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ── Sol animado ──────────────────────────────────────────
            _SolRacha(dias: 14, isDark: isDark),
            const SizedBox(height: 28),
            Text(
              '¡Tu fuego interno brilla con fuerza!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Has estudiado náhuatl por 12 días seguidos.\nTonatiuh te sonríe hoy.',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // ── Días de la semana ────────────────────────────────────
            _DiasSemanales(
                dias: semana, hoyIndex: hoyIndex, isDark: isDark),
            const SizedBox(height: 24),

            // ── Botón mantener fuego ────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_fire_department, size: 18),
                label: const Text('Mantener el Fuego',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5B731),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Calendario ──────────────────────────────────────────
            _CalendarioRacha(isDark: isDark),
            const SizedBox(height: 24),

            // ── Protector de racha ───────────────────────────────────
            _ProtectorRacha(isDark: isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.fondoOscuro : const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text('Tus Insignias',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textoClaro
                    : AppColors.textoSecundario)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // ── Insignia destacada ───────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secundario,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secundario.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textoClaro
                      : AppColors.textoSecundario),
            ),
            const SizedBox(height: 6),
            Text(
              '10 de 100 desbloqueados',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.1,
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.secundario),
              ),
            ),
            const SizedBox(height: 28),
            // Grid de insignias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _insignias.length,
              itemBuilder: (_, i) =>
                  _GridInsignia(insignia: _insignias[i], isDark: isDark),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Colors.grey.shade500,
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
        color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
                    color: Colors.grey.withValues(alpha: 0.1)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark ? AppColors.textoClaro : AppColors.textoSecundario)),
      subtitle: subtitulo != null
          ? Text(subtitulo!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20)
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
        color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: iconColor, size: 16),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textoClaro
                      : AppColors.textoSecundario)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: desbloqueada
                ? AppColors.secundario.withValues(alpha: 0.15)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100),
            shape: BoxShape.circle,
            border: Border.all(
              color: desbloqueada
                  ? AppColors.secundario.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: desbloqueada
                ? Text(emoji, style: const TextStyle(fontSize: 26))
                : Icon(Icons.lock_outline,
                    color: Colors.grey.shade400, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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
          nivelColor: const Color(0xFF5B8DEF),
          desc: 'Master fluency and complex metaphors.',
          completada: false,
          activa: false),
      _Etapa(
          nombre: 'Espada de Jade',
          nivel: 'AVANZADO',
          nivelColor: const Color(0xFF5B8DEF),
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
          desc:
              'Conceptos básicos, saludos y sustantivos comunes.',
          completada: true,
          activa: false),
    ];

    return Column(
      children: etapas.asMap().entries.map((e) {
        final isLast = e.key == etapas.length - 1;
        return _FilaEtapa(
            etapa: e.value, isDark: isDark, isLast: isLast);
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
          // Línea + punto
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
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.shade300),
                    shape: BoxShape.circle,
                    border: etapa.activa
                        ? Border.all(
                            color: AppColors.secundario, width: 3)
                        : null,
                  ),
                  child: etapa.completada
                      ? const Icon(Icons.check, size: 10,
                          color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: etapa.activa
                  ? Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.secundario
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.secundario
                                .withValues(alpha: 0.3)),
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
                                      color: isDark
                                          ? AppColors.textoClaro
                                          : AppColors.textoSecundario)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secundario,
                                  borderRadius:
                                      BorderRadius.circular(6),
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
                                  color: Colors.grey.shade600,
                                  height: 1.4)),
                          if (etapa.xp != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(etapa.xp!,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secundario)),
                                Text('Week ly',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
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
                                    color: isDark
                                        ? AppColors.textoClaro
                                        : AppColors.textoSecundario)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: etapa.nivelColor
                                    .withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(6),
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
                                color: Colors.grey.shade500,
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
        color: AppColors.secundario.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.secundario.withValues(alpha: 0.25)),
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
                      color: isDark
                          ? AppColors.textoClaro
                          : AppColors.textoSecundario)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A838).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Esta semana',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8A838))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completa 5 lecciones de "Comida y Mercado" para ganar el escudo Azteca.',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.4,
              minHeight: 7,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.secundario),
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
              color: Color(0xFFF5B731),
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
      ..color = const Color(0xFFF5B731)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final paintGris = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const rayos = 12;
    const innerR = 68.0;
    const outerR = 88.0;

    for (int i = 0; i < rayos; i++) {
      final angle = (i * 2 * math.pi) / rayos - math.pi / 2;
      final start = Offset(
          center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle));
      final end = Offset(
          center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle));
      // Primeros 8 rayos en amarillo, resto en gris
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
                        ? const Color(0xFFF5B731)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.grey.shade100),
                shape: BoxShape.circle,
                border: esHoy && !completado
                    ? Border.all(
                        color: const Color(0xFFF5B731), width: 2)
                    : null,
              ),
              child: Icon(
                completado ? Icons.check : Icons.local_fire_department,
                size: 16,
                color: completado || esHoy
                    ? Colors.white
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 6),
            Text(_labels[i],
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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
    // Días de marzo 2026 con racha (simplificado)
    final diasConRacha = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13};
    const hoy = 14;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Header mes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Marzo 2026',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textoClaro
                          : AppColors.textoSecundario)),
              Row(
                children: [
                  Icon(Icons.chevron_left,
                      color: Colors.grey.shade400, size: 20),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cabecera días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                .map((d) => SizedBox(
                      width: 32,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid días (marzo 2026 empieza en domingo)
          _GridCalendario(
              diasConRacha: diasConRacha,
              hoy: hoy,
              totalDias: 31,
              primerDia: 0, // domingo
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
                color: esHoy
                    ? const Color(0xFFF5B731)
                    : tieneRacha
                        ? Colors.transparent
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: tieneRacha && !esHoy
                    ? const Text('★',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFFF5B731)))
                    : Text(
                        '$dia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: esHoy
                              ? FontWeight.w900
                              : FontWeight.w500,
                          color: esHoy
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textoClaro
                                  : AppColors.textoSecundario),
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
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF5B8DEF).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5B8DEF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined,
                color: Color(0xFF5B8DEF), size: 20),
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
                        color: isDark
                            ? AppColors.textoClaro
                            : AppColors.textoSecundario)),
                const SizedBox(height: 3),
                Text(
                  'Equipado. Tu racha está segura por hoy si olvidas practicar.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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
                ? AppColors.secundario.withValues(alpha: 0.12)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade100),
            shape: BoxShape.circle,
            border: Border.all(
              color: insignia.desbloqueada
                  ? AppColors.secundario.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Center(
            child: insignia.desbloqueada
                ? Text(insignia.emoji,
                    style: const TextStyle(fontSize: 30))
                : Icon(Icons.lock_outline,
                    color: Colors.grey.shade300, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          insignia.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textoClaro : AppColors.textoSecundario,
          ),
        ),
        if (!insignia.desbloqueada)
          Text(
            'Bloqueado',
            style:
                TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
      ],
    );
  }
}