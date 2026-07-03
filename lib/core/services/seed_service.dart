import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SeedResult {
  final int escrituras;
  final String resumen;

  const SeedResult({required this.escrituras, required this.resumen});
}

class SeedService {
  static final _db = FirebaseFirestore.instance;

  // ── Ejercicios ────────────────────────────────────────────────────────────
  /// Carga assets/ejercicios.json y sube cada ejercicio a ejercicios/{ejercicio_id}.
  /// Usa batches de 400 para respetar el límite de Firestore (500 ops/batch).
  /// Llama [onProgress] con el número de documentos escritos hasta ese momento.

  static Future<SeedResult> subirEjercicios({
    void Function(int escritas, int total)? onProgress,
  }) async {
    final raw  = await rootBundle.loadString('assets/ejercicios.json');
    final List<dynamic> lista = jsonDecode(raw);
    final total = lista.length;
    int escritas = 0;

    const batchSize = 400;
    for (var i = 0; i < lista.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = lista.sublist(i, min(i + batchSize, lista.length));

      for (final item in chunk) {
        final m = item as Map<String, dynamic>;
        final id = (m['ejercicio_id'] as String).trim();

        // Convierte opciones de "a|b|c" a lista
        final opcionesRaw = m['opciones'] as String? ?? '';
        final opciones = opcionesRaw.trim().isEmpty
            ? <String>[]
            : opcionesRaw.split('|').map((s) => s.trim()).toList();

        batch.set(
          _db.collection('ejercicios').doc(id),
          {
            'tipo_ejercicio': m['tipo_ejercicio'] ?? '',
            'vocab_id':       m['vocab_id']       ?? '',
            'frase_id':       m['frase_id']       ?? '',
            'contenido':      m['contenido']      ?? '',
            'respuesta':      m['respuesta']      ?? '',
            'opciones':       opciones,
            'categoria':      m['categoria']      ?? '',
            'dificultad':     m['dificultad']     ?? '',
            'pista':          m['pista']          ?? '',
            'imagen_url':     m['imagen_url']     ?? '',
            'creado_por':     'sistema',
          },
          SetOptions(merge: true),
        );
        escritas++;
      }

      await batch.commit();
      onProgress?.call(escritas, total);
    }

    return SeedResult(
      escrituras: escritas,
      resumen: '$escritas ejercicios subidos a ejercicios/',
    );
  }

  // ── Cursos ────────────────────────────────────────────────────────────────
  /// Carga assets/cursos.json y sube:
  ///   cursos/{id}
  ///   cursos/{id}/modulos/{autoId}
  ///   cursos/{id}/modulos/{autoId}/lecciones/{autoId}
  /// Llama [onProgress] con cuántos cursos se han procesado.

  static Future<SeedResult> subirCursos({
    void Function(int procesados, int total)? onProgress,
  }) async {
    final raw  = await rootBundle.loadString('assets/cursos.json');
    final List<dynamic> lista = jsonDecode(raw);
    final total = lista.length;

    int cursos    = 0;
    int modulos   = 0;
    int lecciones = 0;

    for (final item in lista) {
      final c     = item as Map<String, dynamic>;
      final cursoId = (c['id'] as String).trim();

      // ── Documento de curso ─────────────────────────────────────────────
      await _db.collection('cursos').doc(cursoId).set(
        {
          'titulo':           c['titulo']           ?? '',
          'descripcion':      c['descripcion']      ?? '',
          'nivel':            c['nivel']            ?? '',
          'categoria':        c['categoria']        ?? 'General',
          'imagen_url':       c['imagen_url']       ?? '',
          'publicado':        c['publicado']        ?? false,
          'creado_por':       c['creado_por']       ?? 'sistema',
          'suscritos_count':  c['suscritos_count']  ?? 0,
          'ejercicios_count': c['ejercicios_count'] ?? 0,
          'modulos_count':    c['modulos_count']    ?? 0,
          'lecciones_count':  c['lecciones_count']  ?? 0,
        },
        SetOptions(merge: true),
      );
      cursos++;

      // ── Módulos ────────────────────────────────────────────────────────
      final listaModulos = c['modulos'] as List<dynamic>? ?? [];
      for (final modItem in listaModulos) {
        final m = modItem as Map<String, dynamic>;

        final moduloRef = _db
            .collection('cursos')
            .doc(cursoId)
            .collection('modulos')
            .doc(); // auto-ID

        await moduloRef.set({
          'titulo':      m['titulo']      ?? '',
          'descripcion': m['descripcion'] ?? '',
          'orden':       m['orden']       ?? 0,
        });
        modulos++;

        // ── Lecciones ────────────────────────────────────────────────────
        final listaLecciones = m['lecciones'] as List<dynamic>? ?? [];

        // Batch de lecciones para evitar múltiples round-trips
        final batch = _db.batch();
        for (final lecItem in listaLecciones) {
          final l        = lecItem as Map<String, dynamic>;
          final leccionRef = moduloRef.collection('lecciones').doc();
          batch.set(leccionRef, {
            'titulo':        l['titulo']        ?? '',
            'descripcion':   l['descripcion']   ?? '',
            'orden':         l['orden']         ?? 0,
            'ejercicios_ids': List<String>.from(l['ejercicios_ids'] ?? []),
          });
          lecciones++;
        }
        if (listaLecciones.isNotEmpty) await batch.commit();
      }

      onProgress?.call(cursos, total);
    }

    return SeedResult(
      escrituras: cursos + modulos + lecciones,
      resumen:
          '$cursos cursos · $modulos módulos · $lecciones lecciones subidos',
    );
  }

  // ── Palabras ──────────────────────────────────────────────────────────────
  /// Carga assets/palabras_actualizado.csv y sube cada palabra a palabras/{vocab_id}.
  /// Maneja campos entre comillas con comas internas (RFC 4180).

  static Future<SeedResult> subirPalabras({
    void Function(int escritas, int total)? onProgress,
  }) async {
    final raw   = await rootBundle.loadString('assets/palabras_actualizado.csv');
    final lines = raw
        .split('\n')
        .map((l) => l.trimRight())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length < 2) {
      return const SeedResult(escrituras: 0, resumen: 'CSV vacío o sin filas de datos');
    }

    // Índices de columnas a partir de la cabecera
    final header          = _parsearLineaCsv(lines[0]);
    final idxId           = header.indexOf('vocab_id');
    final idxPalabra      = header.indexOf('palabra_nahuatl');
    final idxTraduccion   = header.indexOf('traduccion_espanol');
    final idxVariante     = header.indexOf('variante_nahuatl');
    final idxCategoria    = header.indexOf('categoria');
    final idxDificultad   = header.indexOf('dificultad');
    final idxImagenUrl    = header.indexOf('imagen_url');

    final rows  = lines.skip(1).toList();
    final total = rows.length;
    int escritas = 0;

    String campo(List<String> fields, int idx) =>
        (idx >= 0 && idx < fields.length) ? fields[idx].trim() : '';

    const batchSize = 400;
    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = rows.sublist(i, min(i + batchSize, rows.length));

      for (final linea in chunk) {
        final fields = _parsearLineaCsv(linea);
        if (fields.length <= 1) continue;

        final vocabId = campo(fields, idxId);
        if (vocabId.isEmpty) continue;

        batch.set(
          _db.collection('palabras').doc(vocabId),
          {
            'palabra_nahuatl':    campo(fields, idxPalabra),
            'traduccion_espanol': campo(fields, idxTraduccion),
            'variante_nahuatl':   campo(fields, idxVariante),
            'categoria':          campo(fields, idxCategoria),
            'dificultad':         campo(fields, idxDificultad),
            'imagen_url':         campo(fields, idxImagenUrl),
          },
          SetOptions(merge: true),
        );
        escritas++;
      }

      await batch.commit();
      onProgress?.call(escritas, total);
    }

    return SeedResult(
      escrituras: escritas,
      resumen: '$escritas palabras subidas a palabras/',
    );
  }

  // ── Parser CSV (RFC 4180) ─────────────────────────────────────────────────
  /// Divide una línea CSV respetando campos entre comillas con comas internas.

  static List<String> _parsearLineaCsv(String linea) {
    final campos  = <String>[];
    final buffer  = StringBuffer();
    bool enComillas = false;

    for (int i = 0; i < linea.length; i++) {
      final c = linea[i];

      if (c == '"') {
        // Comilla escapada ("") dentro de un campo entre comillas
        if (enComillas && i + 1 < linea.length && linea[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          enComillas = !enComillas;
        }
      } else if (c == ',' && !enComillas) {
        campos.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(c);
      }
    }
    campos.add(buffer.toString());
    return campos;
  }
}
