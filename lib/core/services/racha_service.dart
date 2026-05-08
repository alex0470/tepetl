import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Modelo ────────────────────────────────────────────────────────────────────

class DatosRacha {
  final int rachaActual;
  final int mejorRacha;
  final bool rachaActiva;        // el usuario ya completó algo hoy
  final bool protectorActivo;
  final int diasConsecutivos;    // racha consecutiva ininterrumpida (para saber cuándo reactivar protector)
  final List<String> diasConRacha; // 'YYYY-MM-DD' de días con actividad real

  const DatosRacha({
    required this.rachaActual,
    required this.mejorRacha,
    required this.rachaActiva,
    required this.protectorActivo,
    required this.diasConsecutivos,
    required this.diasConRacha,
  });

  static DatosRacha get vacio => const DatosRacha(
        rachaActual: 0,
        mejorRacha: 0,
        rachaActiva: false,
        protectorActivo: false,
        diasConsecutivos: 0,
        diasConRacha: [],
      );

  /// Días de la semana actual Mon→Sun (índice 0=Lunes, 6=Domingo).
  /// true si ese día tuvo actividad registrada.
  List<bool> get semanaActual {
    final hoy = DateTime.now();
    final lunes = hoy.subtract(Duration(days: hoy.weekday - 1));
    return List.generate(7, (i) {
      final dia = lunes.add(Duration(days: i));
      if (dia.isAfter(hoy)) return false;
      return diasConRacha.contains(_fmt(dia));
    });
  }

  /// Índice del día de hoy en la semana (0=Lunes, 6=Domingo).
  int get hoyEnSemana => DateTime.now().weekday - 1;

  /// Números de día del mes con racha para el mes/año dado.
  Set<int> diasDelMes(int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    return diasConRacha
        .where((d) => d.startsWith(prefix))
        .map((d) => int.parse(d.split('-')[2]))
        .toSet();
  }

  /// Días necesarios para que el protector se reactive (0 si ya está activo).
  int get diasParaReactivarProtector =>
      protectorActivo ? 0 : (2 - diasConsecutivos).clamp(0, 2);

  String get mensajeMotivacional {
    if (rachaActual == 0 || !rachaActiva) {
      return 'Practica hoy para mantener tu racha.';
    }
    if (rachaActual < 3)  return '¡Buen comienzo! Sigue así.';
    if (rachaActual < 7)  return '¡Tu fuego comienza a arder!';
    if (rachaActual < 14) return '¡Tu fuego interno brilla con fuerza!';
    if (rachaActual < 30) return '¡Eres imparable! Tonatiuh te sonríe hoy.';
    return '¡Maestro del Náhuatl! Tu racha es legendaria.';
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ── Servicio ──────────────────────────────────────────────────────────────────

class RachaService {
  static final _db = FirebaseFirestore.instance;

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DatosRacha _parse(Map<String, dynamic> data) {
    final rachaActual    = data['racha_actual']       as int?  ?? 0;
    final mejorRacha     = data['mejor_racha']        as int?  ?? 0;
    final protector      = data['protector_activo']   as bool? ?? false;
    final diasCons       = data['dias_consecutivos']  as int?  ?? 0;
    final diasRaw        = data['dias_racha']         as List<dynamic>? ?? [];
    final diasConRacha   = diasRaw.whereType<String>().toList();
    final rachaActiva    = diasConRacha.contains(_fmt(DateTime.now()));

    return DatosRacha(
      rachaActual:     rachaActual,
      mejorRacha:      mejorRacha,
      rachaActiva:     rachaActiva,
      protectorActivo: protector,
      diasConsecutivos: diasCons,
      diasConRacha:    diasConRacha,
    );
  }

  // ── Stream ────────────────────────────────────────────────────────────────

  static Stream<DatosRacha> streamRacha() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(DatosRacha.vacio);
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? _parse(doc.data()!) : DatosRacha.vacio);
  }

  // ── Verificar al abrir la app ─────────────────────────────────────────────
  /// Detecta si la racha expiró o si el protector debe consumirse.
  /// Llamar en initState de la pantalla principal.
  static Future<void> verificarRacha() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return;
    final data = doc.data()!;

    final ultimaTs = data['ultima_actividad'] as Timestamp?;
    if (ultimaTs == null) return;

    final ultima = ultimaTs.toDate();
    final hoy    = DateTime.now();

    final ultimaStr  = _fmt(ultima);
    final hoyStr     = _fmt(hoy);
    final ayerStr    = _fmt(hoy.subtract(const Duration(days: 1)));
    final hace2Str   = _fmt(hoy.subtract(const Duration(days: 2)));

    // Ya registró actividad hoy o ayer → nada que hacer
    if (ultimaStr == hoyStr || ultimaStr == ayerStr) return;

    final protector   = data['protector_activo'] as bool? ?? false;
    final rachaActual = data['racha_actual']      as int?  ?? 0;

    if (ultimaStr == hace2Str && protector) {
      // El protector salva la racha: se consume y se adelanta ultima_actividad a ayer
      // para que el próximo registrarActividad cuente como día consecutivo.
      await _db.collection('users').doc(uid).update({
        'protector_activo':  false,
        'dias_consecutivos': 0,
        'ultima_actividad':  Timestamp.fromDate(DateTime(hoy.year, hoy.month, hoy.day - 1)),
      });
      return;
    }

    // Racha perdida (más de 2 días sin actividad, o 2 días sin protector)
    if (rachaActual > 0) {
      await _db.collection('users').doc(uid).update({
        'racha_actual':      0,
        'protector_activo':  false,
        'dias_consecutivos': 0,
      });
    }
  }

  // ── Registrar actividad ───────────────────────────────────────────────────
  /// Llamar cuando el usuario completa una lección.
  static Future<void> registrarActividad() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc  = await _db.collection('users').doc(uid).get();
    final data = doc.exists ? doc.data()! : <String, dynamic>{};

    final hoy     = DateTime.now();
    final hoyStr  = _fmt(hoy);
    final ayerStr = _fmt(hoy.subtract(const Duration(days: 1)));

    final diasRaw    = data['dias_racha'] as List<dynamic>? ?? [];
    final diasConRacha = diasRaw.whereType<String>().toList();

    // Ya registrado hoy
    if (diasConRacha.contains(hoyStr)) return;

    final ultimaTs  = data['ultima_actividad'] as Timestamp?;
    final ultimaStr = ultimaTs != null ? _fmt(ultimaTs.toDate()) : '';

    int  racha    = data['racha_actual']       as int?  ?? 0;
    int  mejor    = data['mejor_racha']        as int?  ?? 0;
    bool protect  = data['protector_activo']   as bool? ?? false;
    int  diasCons = data['dias_consecutivos']  as int?  ?? 0;

    if (ultimaStr == ayerStr) {
      // Día consecutivo (incluye el caso donde verificarRacha adelantó ultima a ayer tras usar protector)
      racha++;
      diasCons++;
    } else if (ultimaStr.isEmpty) {
      racha    = 1;
      diasCons = 1;
    } else {
      // No hay continuidad (días no consecutivos sin protector)
      racha    = 1;
      diasCons = 1;
      protect  = false;
    }

    // Activar protector al llegar a 2 días consecutivos reales
    if (!protect && diasCons >= 2) protect = true;
    if (racha > mejor) mejor = racha;

    diasConRacha.add(hoyStr);

    await _db.collection('users').doc(uid).update({
      'racha_actual':      racha,
      'mejor_racha':       mejor,
      'protector_activo':  protect,
      'dias_consecutivos': diasCons,
      'ultima_actividad':  FieldValue.serverTimestamp(),
      'dias_racha':        diasConRacha,
    });
  }
}
