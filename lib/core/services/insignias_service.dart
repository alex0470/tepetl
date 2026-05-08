import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tepetl/core/services/niveles_service.dart';

// ── Categorías de insignia ────────────────────────────────────────────────────

enum InsigniaCategoria {
  basico,
  basicoPlus,
  intermedio;

  String get nombre {
    switch (this) {
      case basico:     return 'Básico';
      case basicoPlus: return 'Básico+';
      case intermedio: return 'Intermedio';
    }
  }

  Color get color {
    switch (this) {
      case basico:     return const Color(0xFF64B5F6);
      case basicoPlus: return const Color(0xFF4CAF50);
      case intermedio: return const Color(0xFFFF9800);
    }
  }

  /// Convierte la categoría del nivel del usuario en la categoría de insignia equivalente.
  static InsigniaCategoria desdeNivel(NivelCategoria cat) {
    switch (cat) {
      case NivelCategoria.basico:     return InsigniaCategoria.basico;
      case NivelCategoria.basicoPlus: return InsigniaCategoria.basicoPlus;
      case NivelCategoria.intermedio: return InsigniaCategoria.intermedio;
    }
  }

  /// true si `otra` categoría es accesible para un usuario de esta categoría.
  /// basico=0 < basicoPlus=1 < intermedio=2 (orden natural del enum).
  bool puedeAcceder(InsigniaCategoria otra) => otra.index <= index;
}

// ── Definición de insignia ────────────────────────────────────────────────────

class InsigniaDef {
  final String id;
  final IconData icono;
  final String nombre;
  final String descripcion;
  final InsigniaCategoria categoria;

  const InsigniaDef({
    required this.id,
    required this.icono,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
  });
}

// ── Datos del usuario ─────────────────────────────────────────────────────────

class DatosInsignias {
  final int xp;
  final int rachaActual;
  final int leccionesTotales;
  final int cursosTotales;
  final Set<String> insigniasDesbloqueadas;
  final Set<String> tiposEjerciciosCompletados;
  /// Categoría máxima de insignia que puede desbloquear según su nivel XP.
  final InsigniaCategoria categoriaPermitida;

  const DatosInsignias({
    required this.xp,
    required this.rachaActual,
    required this.leccionesTotales,
    required this.cursosTotales,
    required this.insigniasDesbloqueadas,
    required this.tiposEjerciciosCompletados,
    required this.categoriaPermitida,
  });

  static DatosInsignias get vacio => const DatosInsignias(
        xp: 0, rachaActual: 0, leccionesTotales: 0, cursosTotales: 0,
        insigniasDesbloqueadas: {}, tiposEjerciciosCompletados: {},
        categoriaPermitida: InsigniaCategoria.basico,
      );

  bool tieneInsignia(String id)           => insigniasDesbloqueadas.contains(id);
  bool puedeDesbloquear(InsigniaDef def)  => categoriaPermitida.puedeAcceder(def.categoria);
  int  get totalDesbloqueadas             => insigniasDesbloqueadas.length;
}

// ── Servicio ──────────────────────────────────────────────────────────────────

class InsigniasService {
  static final _db = FirebaseFirestore.instance;

  // ── Catálogo completo ─────────────────────────────────────────────────────

  static const List<InsigniaDef> todas = [
    // ── BÁSICO (12) ──────────────────────────────────────────────────────────
    InsigniaDef(id: 'primer_dia',          icono: Icons.star_outline,                   nombre: 'Chispa Inicial',        descripcion: 'Tu primer día con racha activa',                categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'primera_leccion',     icono: Icons.school_outlined,                nombre: 'Primer Paso',           descripcion: 'Completa tu primera lección',                   categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'lecciones_3',         icono: Icons.auto_stories_outlined,          nombre: 'Curioso',               descripcion: 'Completa 3 lecciones',                          categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'lecciones_5',         icono: Icons.menu_book_outlined,             nombre: 'Dedicado',              descripcion: 'Completa 5 lecciones',                          categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'ejercicio_escribir',  icono: Icons.edit_outlined,                  nombre: 'Pluma del Escriba',     descripcion: 'Completa un ejercicio de escritura',            categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'ejercicio_imagen',    icono: Icons.image_outlined,                 nombre: 'Ojo Sagrado',           descripcion: 'Completa un ejercicio de imágenes',             categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'ejercicio_completar', icono: Icons.spellcheck,                     nombre: 'Tejedor de Palabras',   descripcion: 'Completa un ejercicio de completar frases',     categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'racha_3',             icono: Icons.local_fire_department_outlined, nombre: 'Chispa',                descripcion: '3 días de racha seguidos',                      categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'racha_5',             icono: Icons.whatshot,                       nombre: 'Llama',                 descripcion: '5 días de racha seguidos',                      categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'xp_50',              icono: Icons.bolt,                            nombre: 'Primera Chispa XP',     descripcion: 'Acumula 50 XP',                                 categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'nivel_2',             icono: Icons.shield_outlined,                nombre: 'Guerrero',              descripcion: 'Alcanza el rango Guerrero (100 XP)',            categoria: InsigniaCategoria.basico),
    InsigniaDef(id: 'nivel_3',             icono: Icons.nights_stay_outlined,           nombre: 'Chamán',                descripcion: 'Alcanza el rango Chamán (220 XP)',              categoria: InsigniaCategoria.basico),

    // ── BÁSICO+ (14) ─────────────────────────────────────────────────────────
    InsigniaDef(id: 'lecciones_10',        icono: Icons.library_books_outlined,         nombre: 'Estudioso',             descripcion: 'Completa 10 lecciones',                         categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'lecciones_15',        icono: Icons.fact_check_outlined,            nombre: 'Perseverante',          descripcion: 'Completa 15 lecciones',                         categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'lecciones_25',        icono: Icons.military_tech,                  nombre: 'Constante',             descripcion: 'Completa 25 lecciones',                         categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'racha_7',             icono: Icons.star_outline,                   nombre: 'Llama Viva',            descripcion: '7 días de racha seguidos',                      categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'racha_10',            icono: Icons.trending_up,                    nombre: 'Fuego Fiel',            descripcion: '10 días de racha seguidos',                     categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'racha_14',            icono: Icons.wb_sunny_outlined,              nombre: 'Imparable',             descripcion: '14 días de racha seguidos',                     categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'xp_100',             icono: Icons.stars,                           nombre: 'Centelleo',             descripcion: 'Acumula 100 XP',                                categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'xp_250',             icono: Icons.diamond_outlined,               nombre: 'Jade',                  descripcion: 'Acumula 250 XP',                                categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'xp_500',             icono: Icons.auto_awesome_outlined,           nombre: 'Obsidiana',             descripcion: 'Acumula 500 XP',                                categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'primer_curso',        icono: Icons.workspace_premium_outlined,     nombre: 'Explorador',            descripcion: 'Completa tu primer curso',                      categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'cursos_2',            icono: Icons.collections_bookmark_outlined,  nombre: 'Viajero',               descripcion: 'Completa 2 cursos',                             categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'nivel_5',             icono: Icons.pets,                           nombre: 'Señor Jaguar',          descripcion: 'Alcanza el rango Señor Jaguar (530 XP)',        categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'nivel_7',             icono: Icons.menu_book,                      nombre: 'Tejedor de Historias',  descripcion: 'Alcanza el nivel 7 (970 XP)',                   categoria: InsigniaCategoria.basicoPlus),
    InsigniaDef(id: 'nivel_8',             icono: Icons.water_drop_outlined,            nombre: 'Guardián del Agua',     descripcion: 'Alcanza el nivel 8 (1250 XP)',                  categoria: InsigniaCategoria.basicoPlus),

    // ── INTERMEDIO (14) ──────────────────────────────────────────────────────
    InsigniaDef(id: 'lecciones_50',        icono: Icons.psychology_outlined,            nombre: 'Metamorfosis',          descripcion: 'Completa 50 lecciones',                         categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'lecciones_75',        icono: Icons.emoji_objects_outlined,         nombre: 'Guardián del Saber',    descripcion: 'Completa 75 lecciones',                         categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'lecciones_100',       icono: Icons.workspace_premium,             nombre: 'Centurión',             descripcion: 'Completa 100 lecciones',                        categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'racha_21',            icono: Icons.brightness_5,                   nombre: 'Tres Semanas',          descripcion: '21 días de racha seguidos',                     categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'racha_30',            icono: Icons.emoji_events_outlined,          nombre: 'Guerrero Águila',       descripcion: '30 días de racha seguidos',                     categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'racha_60',            icono: Icons.celebration_outlined,           nombre: 'Llama Inmortal',        descripcion: '60 días de racha seguidos',                     categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'racha_100',           icono: Icons.wb_sunny,                       nombre: 'Sol Eterno',            descripcion: '100 días de racha seguidos',                    categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'xp_1000',            icono: Icons.terrain_outlined,               nombre: 'Llama Eterna',          descripcion: 'Acumula 1000 XP',                               categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'xp_1500',            icono: Icons.diamond,                        nombre: 'Gran Fuego',            descripcion: 'Acumula 1500 XP',                               categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'xp_2000',            icono: Icons.auto_awesome,                   nombre: 'Gran Jade',             descripcion: 'Acumula 2000 XP',                               categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'cursos_3',            icono: Icons.temple_buddhist_outlined,       nombre: 'Guardián del Templo',   descripcion: 'Completa 3 cursos',                             categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'cursos_5',            icono: Icons.collections_bookmark,           nombre: 'Conquistador',          descripcion: 'Completa 5 cursos',                             categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'nivel_10',            icono: Icons.terrain,                        nombre: 'Guardián de la Tierra', descripcion: 'Alcanza el nivel 10 (1960 XP)',                 categoria: InsigniaCategoria.intermedio),
    InsigniaDef(id: 'nivel_20',            icono: Icons.temple_hindu,                   nombre: 'Gran Sacerdote',        descripcion: 'Alcanza el nivel 20 (9500 XP)',                 categoria: InsigniaCategoria.intermedio),
  ];

  static List<InsigniaDef> porCategoria(InsigniaCategoria cat) =>
      todas.where((i) => i.categoria == cat).toList();

  // ── Stream ────────────────────────────────────────────────────────────────

  static Stream<DatosInsignias> streamDatos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(DatosInsignias.vacio);

    return _db.collection('users').doc(uid).snapshots().asyncMap((userDoc) async {
      final insigniasSnap = await _db
          .collection('users').doc(uid).collection('insignias').get();
      final desbloqueadas = insigniasSnap.docs.map((d) => d.id).toSet();

      final d = userDoc.data() ?? {};
      final xp = d['xp'] as int? ?? 0;
      final nivelCat = InsigniaCategoria.desdeNivel(
        NivelesService.getNivelByXP(xp).categoria,
      );

      return DatosInsignias(
        xp:               xp,
        rachaActual:      d['racha_actual']      as int? ?? 0,
        leccionesTotales: d['lecciones_totales'] as int? ?? 0,
        cursosTotales:    d['cursos_completados'] as int? ?? 0,
        insigniasDesbloqueadas: desbloqueadas,
        tiposEjerciciosCompletados: Set<String>.from(
            (d['tipos_ejercicios_completados'] as List<dynamic>? ?? []).whereType<String>()),
        categoriaPermitida: nivelCat,
      );
    });
  }

  // ── Verificar y otorgar ───────────────────────────────────────────────────
  /// Solo otorga insignias que corresponden al nivel educativo del usuario.

  static Future<void> verificarYOtorgarInsignias({
    Set<String> tiposEjerciciosEnLeccion = const {},
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return;
    final d = userDoc.data()!;

    final xp        = d['xp']               as int? ?? 0;
    final racha     = d['racha_actual']      as int? ?? 0;
    final lecciones = d['lecciones_totales'] as int? ?? 0;
    final cursos    = d['cursos_completados'] as int? ?? 0;
    final tiposGuardados = Set<String>.from(
        (d['tipos_ejercicios_completados'] as List<dynamic>? ?? []).whereType<String>());
    final todosLosTipos = {...tiposGuardados, ...tiposEjerciciosEnLeccion};

    // Categoría máxima disponible según nivel XP
    final catPermitida = InsigniaCategoria.desdeNivel(
      NivelesService.getNivelByXP(xp).categoria,
    );

    // Insignias ya desbloqueadas
    final insigniasSnap = await _db
        .collection('users').doc(uid).collection('insignias').get();
    final desbloqueadas = insigniasSnap.docs.map((d) => d.id).toSet();

    final nuevas = <InsigniaDef>[];
    for (final def in todas) {
      // Restricción: solo se pueden obtener insignias de la categoría del usuario o inferior
      if (!catPermitida.puedeAcceder(def.categoria)) continue;
      if (desbloqueadas.contains(def.id)) continue;
      if (_cumpleCondicion(def.id, xp, racha, lecciones, cursos, todosLosTipos)) {
        nuevas.add(def);
      }
    }

    if (nuevas.isEmpty && tiposEjerciciosEnLeccion.isEmpty) return;

    final batch = _db.batch();
    final ahora = Timestamp.now();

    for (final def in nuevas) {
      batch.set(
        _db.collection('users').doc(uid).collection('insignias').doc(def.id),
        {
          'desbloqueadaEn': ahora,
          'nombre':    def.nombre,
          'categoria': def.categoria.name,
        },
      );
    }

    if (tiposEjerciciosEnLeccion.isNotEmpty) {
      batch.update(
        _db.collection('users').doc(uid),
        {'tipos_ejercicios_completados': FieldValue.arrayUnion(tiposEjerciciosEnLeccion.toList())},
      );
    }

    await batch.commit();
  }

  // ── Condiciones de desbloqueo ─────────────────────────────────────────────

  static bool _cumpleCondicion(
    String id, int xp, int racha, int lecciones, int cursos, Set<String> tipos,
  ) {
    switch (id) {
      case 'primer_dia':          return racha >= 1;
      case 'primera_leccion':     return lecciones >= 1;
      case 'lecciones_3':         return lecciones >= 3;
      case 'lecciones_5':         return lecciones >= 5;
      case 'ejercicio_escribir':  return tipos.contains('escribir') || tipos.contains('traducir');
      case 'ejercicio_imagen':    return tipos.contains('imagenes') || tipos.contains('imagen');
      case 'ejercicio_completar': return tipos.contains('completar');
      case 'racha_3':             return racha >= 3;
      case 'racha_5':             return racha >= 5;
      case 'xp_50':               return xp >= 50;
      case 'nivel_2':             return xp >= 100;
      case 'nivel_3':             return xp >= 220;
      case 'lecciones_10':        return lecciones >= 10;
      case 'lecciones_15':        return lecciones >= 15;
      case 'lecciones_25':        return lecciones >= 25;
      case 'racha_7':             return racha >= 7;
      case 'racha_10':            return racha >= 10;
      case 'racha_14':            return racha >= 14;
      case 'xp_100':              return xp >= 100;
      case 'xp_250':              return xp >= 250;
      case 'xp_500':              return xp >= 500;
      case 'primer_curso':        return cursos >= 1;
      case 'cursos_2':            return cursos >= 2;
      case 'nivel_5':             return xp >= 530;
      case 'nivel_7':             return xp >= 970;
      case 'nivel_8':             return xp >= 1250;
      case 'lecciones_50':        return lecciones >= 50;
      case 'lecciones_75':        return lecciones >= 75;
      case 'lecciones_100':       return lecciones >= 100;
      case 'racha_21':            return racha >= 21;
      case 'racha_30':            return racha >= 30;
      case 'racha_60':            return racha >= 60;
      case 'racha_100':           return racha >= 100;
      case 'xp_1000':             return xp >= 1000;
      case 'xp_1500':             return xp >= 1500;
      case 'xp_2000':             return xp >= 2000;
      case 'cursos_3':            return cursos >= 3;
      case 'cursos_5':            return cursos >= 5;
      case 'nivel_10':            return xp >= 1960;
      case 'nivel_20':            return xp >= 9500;
      default:                    return false;
    }
  }
}
