import 'package:flutter/material.dart';
import 'package:tepetl/core/models/modelo_revision.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class RevisionErrores extends StatelessWidget {
  final List<LeccionErrores> errores;

  const RevisionErrores({super.key, required this.errores});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isWide = sw > 700;
    final double contentWidth =
        isWide ? (sw * 0.9).clamp(900, 1300) : double.infinity;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),

            Expanded(
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Column(
                      children: [
                        _OwlBanner(isWide: isWide),
                        const SizedBox(height: 32),

                        isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: errores
                                    .map(
                                      (e) => Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                e != errores.last ? 20 : 0,
                                          ),
                                          child: _ErrorCard(
                                            error: e,
                                            isWide: true,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              )
                            : Column(
                                children: errores
                                    .map((e) =>
                                        _ErrorCard(error: e, isWide: false))
                                    .toList(),
                              ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            _PracticeButton(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(Icons.close,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              'REVISIÓN DE ERRORES',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

//
// ── BANNER ─────────────────────────────────────────
//

class _OwlBanner extends StatelessWidget {
  final bool isWide;
  const _OwlBanner({this.isWide = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isWide ? 90 : 72,
          height: isWide ? 90 : 72,
          decoration: BoxDecoration(
            color: AppColors.secundario.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.emoji_objects,
            size: isWide ? 44 : 36,
            color: AppColors.secundario,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '¡Casi lo tienes!',
          style: TextStyle(
            fontSize: isWide ? 28 : 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Los errores son parte del aprendizaje.\nRevísalos para mejorar tu progreso.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isWide ? 15 : 13,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

//
// ── ERROR CARD ─────────────────────────────────────
//

class _ErrorCard extends StatelessWidget {
  final LeccionErrores error;
  final bool isWide;

  const _ErrorCard({
    required this.error,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg = isDark
        ? AppColors.fondoOscuroSecundario
        : AppColors.fondoSecundario;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ErrorTypeHeader(error: error, isWide: isWide),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isWide ? 20 : 14,
              isWide ? 18 : 12,
              isWide ? 20 : 14,
              isWide ? 20 : 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (error.contenido.isNotEmpty) ...[
                  Text(
                    error.contenido,
                    style: TextStyle(
                      fontSize: isWide ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isWide ? 12 : 8),
                ],
                _AnswerRow(
                  label: 'Tu respuesta',
                  text: error.respuestaUsuario,
                  isCorrect: false,
                  isWide: isWide,
                ),
                const SizedBox(height: 10),
                _AnswerRow(
                  label: 'Correcto',
                  text: error.respuestaCorrecta,
                  isCorrect: true,
                  isWide: isWide,
                ),
                const SizedBox(height: 14),
                _AINoteBox(note: error.notaAI, isWide: isWide),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// ── HEADER TIPO ERROR ──────────────────────────────
//

class _ErrorTypeHeader extends StatelessWidget {
  final LeccionErrores error;
  final bool isWide;

  const _ErrorTypeHeader({required this.error, this.isWide = false});

  Color get _color {
    switch (error.tipo) {
      case TipoError.gramatica:
        return AppColors.amarillo1;
      case TipoError.vocabulario:
        return AppColors.azul1;
      case TipoError.sintaxis:
        return AppColors.morado1;
    }
  }

  IconData get _icon {
    switch (error.tipo) {
      case TipoError.gramatica:
        return Icons.edit_note;
      case TipoError.vocabulario:
        return Icons.menu_book;
      case TipoError.sintaxis:
        return Icons.account_tree_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 18 : 14,
        vertical: isWide ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: isWide ? 20 : 18),
          const SizedBox(width: 8),
          Text(
            error.tipoLabel,
            style: TextStyle(
              fontSize: isWide ? 14 : 12,
              fontWeight: FontWeight.w800,
              color: _color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

//
// ── RESPUESTAS ─────────────────────────────────────
//

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final bool isCorrect;
  final bool isWide;

  const _AnswerRow({
    required this.label,
    required this.text,
    required this.isCorrect,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isCorrect
        ? AppColors.secundario.withValues(alpha: 0.15)
        : Colors.red.withValues(alpha: 0.1);

    final Color textColor =
        isCorrect ? AppColors.secundario : Colors.red;

    final IconData icon = isCorrect ? Icons.check : Icons.close;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 16 : 14,
        vertical: isWide ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isWide ? 13 : 11,
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: isWide ? 20 : 16, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: isWide ? 18 : 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// ── IA NOTE ────────────────────────────────────────
//

class _AINoteBox extends StatelessWidget {
  final String note;
  final bool isWide;

  const _AINoteBox({required this.note, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isWide ? 16 : 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.fondoOscuroSecundario
            : AppColors.fondoSecundario,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome,
              color: AppColors.morado1, size: isWide ? 18 : 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                fontSize: isWide ? 15 : 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ── BOTÓN ──────────────────────────────────────────
//

class _PracticeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Center(
        child: Container(
          width: 300,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.replay, size: 20),
            label: const Text(
              'Practicar de nuevo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secundario,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}