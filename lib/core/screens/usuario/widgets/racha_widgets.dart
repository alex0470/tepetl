import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class SolRacha extends StatelessWidget {
  final int dias;
  final bool activa;
  final List<bool> semana; // índice 0=Lun … 6=Dom

  const SolRacha({
    super.key,
    required this.dias,
    required this.activa,
    required this.semana,
  });

  @override
  Widget build(BuildContext context) {
    final circuloColor = activa ? AppColors.amarillo1 : Colors.grey.shade400;

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _SolPainter(semana: semana, activa: activa),
        child: Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(color: circuloColor, shape: BoxShape.circle),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: activa ? Colors.white : Colors.grey.shade200,
                  size: 22,
                ),
                Text(
                  '$dias',
                  style: TextStyle(
                    color: activa ? Colors.white : Colors.grey.shade200,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                Text(
                  'DÍAS',
                  style: TextStyle(
                    color: activa ? Colors.white70 : Colors.grey.shade300,
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
  final List<bool> semana;
  final bool activa;

  _SolPainter({required this.semana, required this.activa});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paintActivo = Paint()
      ..color = AppColors.amarillo1
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintGris = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const rayos   = 7;
    const innerR  = 68.0;
    const outerR  = 88.0;

    // El primer rayo apunta hacia arriba (12 en punto = Lunes)
    for (int i = 0; i < rayos; i++) {
      final angle = (i * 2 * math.pi) / rayos - math.pi / 2;
      final start = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      final activo = activa && i < semana.length && semana[i];
      canvas.drawLine(start, end, activo ? paintActivo : paintGris);
    }
  }

  @override
  bool shouldRepaint(_SolPainter old) =>
      old.activa != activa || old.semana != semana;
}

class DiasSemanales extends StatelessWidget {
  final List<bool> semana;
  final int hoyIndex;

  const DiasSemanales({
    super.key,
    required this.semana,
    required this.hoyIndex,
  });

  static const _labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final hoy   = DateTime.now();
    final lunes = hoy.subtract(Duration(days: hoy.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final dia        = lunes.add(Duration(days: i));
        final esFuturo   = dia.isAfter(hoy);
        final esHoy      = i == hoyIndex;
        final tieneRacha = !esFuturo && i < semana.length && semana[i];

        Color circuloColor;
        Color iconColor = Colors.white;
        IconData icono  = Icons.local_fire_department;

        if (esFuturo) {
          circuloColor = Colors.grey.shade200;
          iconColor    = Colors.grey.shade400;
        } else if (tieneRacha) {
          circuloColor = esHoy ? AppColors.amarillo1 : AppColors.secundario;
          icono        = Icons.check;
        } else if (esHoy) {
          circuloColor = AppColors.amarillo1.withValues(alpha: 0.25);
          iconColor    = AppColors.amarillo1;
        } else {
          // Día pasado sin racha
          circuloColor = Colors.grey.shade200;
          iconColor    = Colors.grey.shade400;
        }

        return Column(
          children: [
            // Chip "HOY"
            if (esHoy)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secundario,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Hoy',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const SizedBox(height: 18),
            const SizedBox(height: 4),
            // Número del día
            Text(
              '${dia.day}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: esHoy
                    ? AppColors.secundario
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 2),
            // Círculo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: circuloColor,
                shape: BoxShape.circle,
                border: esHoy && !tieneRacha
                    ? Border.all(color: AppColors.amarillo1, width: 2)
                    : null,
              ),
              child: Icon(icono, size: 16, color: iconColor),
            ),
            const SizedBox(height: 5),
            // Etiqueta
            Text(
              _labels[i],
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class CalendarioRacha extends StatefulWidget {
  final bool isDark;
  final Set<int> diasConRacha;

  const CalendarioRacha({
    super.key,
    required this.isDark,
    required this.diasConRacha,
  });

  @override
  State<CalendarioRacha> createState() => _CalendarioRachaState();
}

class _CalendarioRachaState extends State<CalendarioRacha> {
  late int _mes;
  late int _anio;

  bool get _esMesActual {
    final hoy = DateTime.now();
    return _mes == hoy.month && _anio == hoy.year;
  }

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _mes  = hoy.month;
    _anio = hoy.year;
  }

  void _mesAnterior() {
    setState(() {
      if (_mes == 1) {
        _mes  = 12;
        _anio -= 1;
      } else {
        _mes -= 1;
      }
    });
  }

  void _mesSiguiente() {
    final hoy = DateTime.now();
    if (_anio == hoy.year && _mes == hoy.month) return;
    setState(() {
      if (_mes == 12) {
        _mes  = 1;
        _anio += 1;
      } else {
        _mes += 1;
      }
    });
  }

  static const _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final hoy         = DateTime.now();
    final hoyDia      = _esMesActual ? hoy.day : -1;
    final totalDias   = DateTime(_anio, _mes + 1, 0).day;
    final primerDia   = (DateTime(_anio, _mes, 1).weekday - 1) % 7;
    final esMesActual = _esMesActual;
    final hayMesSig   = !(_anio == hoy.year && _mes == hoy.month);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado mes + navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_meses[_mes - 1]} $_anio',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _mesAnterior,
                    child: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ),
                  GestureDetector(
                    onTap: hayMesSig ? _mesSiguiente : null,
                    child: Icon(
                      Icons.chevron_right,
                      color: hayMesSig
                          ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                          : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Cabecera días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                .map((d) => SizedBox(
                      width: 32,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.75),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          _GridCalendario(
            diasConRacha: esMesActual ? widget.diasConRacha : {},
            hoyDia:       hoyDia,
            totalDias:    totalDias,
            primerDia:    primerDia,
          ),
        ],
      ),
    );
  }
}

class _GridCalendario extends StatelessWidget {
  final Set<int> diasConRacha;
  final int hoyDia;
  final int totalDias;
  final int primerDia;

  const _GridCalendario({
    required this.diasConRacha,
    required this.hoyDia,
    required this.totalDias,
    required this.primerDia,
  });

  @override
  Widget build(BuildContext context) {
    final celdas = primerDia + totalDias;
    final filas  = (celdas / 7).ceil();

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
            final esHoy      = dia == hoyDia;

            Color? bgColor;
            Widget child;

            if (esHoy && tieneRacha) {
              bgColor = AppColors.amarillo1;
              child   = const Text('⭐', style: TextStyle(fontSize: 13));
            } else if (esHoy) {
              bgColor = AppColors.amarillo1.withValues(alpha: 0.3);
              child   = Text(
                '$dia',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.amarillo1,
                ),
              );
            } else if (tieneRacha) {
              bgColor = AppColors.secundario.withValues(alpha: 0.15);
              child   = const Text('★', style: TextStyle(fontSize: 13, color: AppColors.secundario));
            } else {
              child = Text(
                '$dia',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              );
            }

            return Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: child),
            );
          }),
        );
      }),
    );
  }
}

class ProtectorRacha extends StatelessWidget {
  final bool isDark;
  final bool activo;
  final int diasParaActivar;

  const ProtectorRacha({
    super.key,
    required this.isDark,
    required this.activo,
    required this.diasParaActivar,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? AppColors.azul1 : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.fondoOscuroSecundario : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: activo ? 0.15 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activo ? Icons.shield : Icons.shield_outlined,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Protector de Racha',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activo ? 'ACTIVO' : 'INACTIVO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activo
                      ? 'Tu racha está protegida. Si fallas un día, la racha sobrevive.'
                      : diasParaActivar == 0
                          ? 'El protector está listo.'
                          : 'Practica $diasParaActivar día${diasParaActivar == 1 ? '' : 's'} más para activarlo.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                if (!activo && diasParaActivar > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(2, (i) {
                      final lleno = i >= diasParaActivar;
                      return Container(
                        width: 28,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: lleno
                              ? AppColors.azul1
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
