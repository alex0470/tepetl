import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/usuario/widgets/dialog_widgets.dart';
import 'package:tepetl/core/services/meta_diaria_service.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class PreferenciasDialog extends StatefulWidget {
  const PreferenciasDialog({super.key});

  @override
  State<PreferenciasDialog> createState() => _PreferenciasDialogState();
}

class _PreferenciasDialogState extends State<PreferenciasDialog> {
  double _metaDiaria = 10;
  bool _recordatorio = true;
  TimeOfDay _horaRecordatorio = const TimeOfDay(hour: 8, minute: 0);
  String _nivelObjetivo = 'Intermedio';
  bool _cargando = true;
  bool _guardando = false;
  int _diasParaCambiar = 0;

  static const _niveles = ['Principiante', 'Intermedio', 'Avanzado', 'Experto'];

  @override
  void initState() {
    super.initState();
    _cargarValores();
  }

  Future<void> _cargarValores() async {
    final meta = await MetaDiariaService.obtenerMeta();
    final puede = await MetaDiariaService.puedeCambiarMeta();
    final dias = puede ? 0 : await MetaDiariaService.diasParaCambiarMeta();
    if (mounted) {
      setState(() {
        _metaDiaria    = meta.toDouble().clamp(5, 60);
        _diasParaCambiar = dias;
        _cargando      = false;
      });
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final guardado = await MetaDiariaService.cambiarMeta(_metaDiaria.toInt());
    if (!mounted) return;
    setState(() => _guardando = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guardado
              ? 'Meta actualizada a ${_metaDiaria.toInt()} min diarios'
              : 'Solo puedes cambiar la meta cada 7 días',
        ),
        backgroundColor: guardado ? null : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final puedeEditar = _diasParaCambiar == 0;

    return Dialog(
      insetPadding: dialogInsetPadding(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.fondoOscuroSecundario : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _cargando
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DialogEncabezado(
                      titulo: 'Preferencias de aprendizaje',
                      icono: Icons.school_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ── Meta diaria ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meta diaria: ${_metaDiaria.toInt()} min',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!puedeEditar)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_diasParaCambiar días',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Slider(
                      value: _metaDiaria,
                      min: 5,
                      max: 60,
                      divisions: 11,
                      activeColor: puedeEditar
                          ? AppColors.secundario
                          : Colors.grey.shade400,
                      label: '${_metaDiaria.toInt()} min',
                      onChanged: puedeEditar
                          ? (v) => setState(() => _metaDiaria = v)
                          : null,
                    ),
                    if (!puedeEditar)
                      Text(
                        'Podrás cambiar la meta en $_diasParaCambiar día${_diasParaCambiar == 1 ? '' : 's'}.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // ── Nivel objetivo ───────────────────────────────────
                    Text(
                      'Nivel objetivo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _niveles.map((n) {
                        final sel = n == _nivelObjetivo;
                        return ChoiceChip(
                          label: Text(n),
                          selected: sel,
                          onSelected: (_) =>
                              setState(() => _nivelObjetivo = n),
                          selectedColor: AppColors.secundario,
                          labelStyle: TextStyle(
                            color: sel ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ── Recordatorio ─────────────────────────────────────
                    FilaSwitch(
                      label: 'Recordatorio diario',
                      value: _recordatorio,
                      onChanged: (v) => setState(() => _recordatorio = v),
                    ),
                    if (_recordatorio) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _horaRecordatorio,
                          );
                          if (t != null) {
                            setState(() => _horaRecordatorio = t);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                AppColors.secundario.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.secundario
                                    .withValues(alpha: 0.3)),
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
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.secundario
                                    .withValues(alpha: 0.6),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Acciones ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.secundario
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _guardando ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secundario,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _guardando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text('Guardar',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700)),
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
}
