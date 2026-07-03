import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';
import 'package:tepetl/core/screens/usuario/widgets/perfil_stats_widgets.dart';
import 'package:tepetl/core/screens/usuario/widgets/racha_widgets.dart';
import 'package:tepetl/core/services/racha_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';

class RachaDiariaScreen extends StatefulWidget {
  const RachaDiariaScreen({super.key});

  @override
  State<RachaDiariaScreen> createState() => _RachaDiariaScreenState();
}

class _RachaDiariaScreenState extends State<RachaDiariaScreen> {
  late final Stream<DatosRacha> _stream;

  @override
  void initState() {
    super.initState();
    _stream = RachaService.streamRacha();
    // Verifica al abrir si la racha expiró o si el protector debe consumirse
    RachaService.verificarRacha();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _irAlInicio() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide      = screenWidth > 700;

    return Scaffold(
      backgroundColor: isDark ? AppColors.fondoOscuro : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: BotonAtras(onPressed: () => Navigator.maybePop(context)),
        title: Text(
          'Racha diaria',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DatosRacha>(
        stream: _stream,
        builder: (context, snap) {
          final datos = snap.data ?? DatosRacha.vacio;
          final semana = datos.semanaActual;
          final hoyIndex = datos.hoyEnSemana;
          final diasCalendario = datos.diasDelMes(
            DateTime.now().year,
            DateTime.now().month,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.03 : 24,
              vertical: 8,
            ),
            child: isWide
                ? _wideLayout(context, isDark, datos, semana, hoyIndex, diasCalendario)
                : _narrowLayout(context, isDark, datos, semana, hoyIndex, diasCalendario),
          );
        },
      ),
    );
  }

  // ── Layout ancho ────────────────────────────────────────────────────────────

  Widget _wideLayout(
    BuildContext context,
    bool isDark,
    DatosRacha datos,
    List<bool> semana,
    int hoyIndex,
    Set<int> diasCalendario,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SolRacha(dias: datos.rachaActual, activa: datos.rachaActiva, semana: semana),
              const SizedBox(height: 28),
              _textoMotivacional(context, datos),
              const SizedBox(height: 28),
              DiasSemanales(semana: semana, hoyIndex: hoyIndex),
              const SizedBox(height: 24),
              _botonMantener(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TarjetaStat(
                      icono: Icons.emoji_events_outlined,
                      iconColor: AppColors.amarillo1,
                      label: 'Mejor racha',
                      valor: '${datos.mejorRacha}',
                      delta: 'Días',
                      deltaColor: AppColors.amarillo1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TarjetaStat(
                      icono: Icons.local_fire_department,
                      iconColor: AppColors.naranja1,
                      label: 'Racha actual',
                      valor: '${datos.rachaActual}',
                      delta: 'Días',
                      deltaColor: AppColors.naranja1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 16),
              CalendarioRacha(isDark: isDark, diasConRacha: diasCalendario),
              const SizedBox(height: 24),
              ProtectorRacha(
                isDark: isDark,
                activo: datos.protectorActivo,
                diasParaActivar: datos.diasParaReactivarProtector,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout(
    BuildContext context,
    bool isDark,
    DatosRacha datos,
    List<bool> semana,
    int hoyIndex,
    Set<int> diasCalendario,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),
        SolRacha(dias: datos.rachaActual, activa: datos.rachaActiva, semana: semana),
        const SizedBox(height: 28),
        _textoMotivacional(context, datos),
        const SizedBox(height: 28),
        DiasSemanales(semana: semana, hoyIndex: hoyIndex),
        const SizedBox(height: 24),
        _botonMantener(),
        const SizedBox(height: 24),
        CalendarioRacha(isDark: isDark, diasConRacha: diasCalendario),
        const SizedBox(height: 24),
        ProtectorRacha(
          isDark: isDark,
          activo: datos.protectorActivo,
          diasParaActivar: datos.diasParaReactivarProtector,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _textoMotivacional(BuildContext context, DatosRacha datos) {
    return Column(
      children: [
        Text(
          datos.rachaActual == 0
              ? '¡Empieza tu racha hoy!'
              : '${datos.rachaActual} días de racha',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          datos.mensajeMotivacional,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _botonMantener() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _irAlInicio,
        icon: const Icon(Icons.local_fire_department, size: 18),
        label: const Text(
          'Mantener el Fuego',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amarillo1,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
