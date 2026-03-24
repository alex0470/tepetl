import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';
import 'package:tepetl/core/widgets/inputs/textfield_pers.dart';

class RecuperarContraScreen extends StatefulWidget {
  const RecuperarContraScreen({super.key});

  @override
  State<RecuperarContraScreen> createState() => _RecuperarContraScreenState();
}

class _RecuperarContraScreenState extends State<RecuperarContraScreen> {
  final _emailCtrl = TextEditingController();

  static const double _kBreakpoint = 700;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double vw = mq.size.width;
    final double vh = mq.size.height;
    final bool isWide = vw >= _kBreakpoint;

    return Scaffold(
      body: isWide
          ? _wideLayout(vw: vw, vh: vh)
          : _narrowLayout(vw: vw, vh: vh),
    );
  }

  Widget _wideLayout({required double vw, required double vh}) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: Stack(
              children: [
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(vw * 0.01),
                      child: const BotonAtras(),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.key_rounded,
                        size: (vw * 0.10).clamp(80, 140),
                        color: AppColors.primario,
                      ),
                      SizedBox(height: vh * 0.03),
                      Text(
                        '¿Olvidaste tu\ncontraseña?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (vw * 0.030).clamp(22, 38),
                          fontWeight: FontWeight.w800,
                          color: AppColors.primario,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: vh * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: vw * 0.04),
                        child: Text(
                          'No te preocupes, el ascenso continúa.\nIngresa tu correo para recibir un enlace de recuperación.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (vw * 0.012).clamp(12, 16),
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: vh * 0.05),
              child: SizedBox(
                width: (vw * 0.45).clamp(380, 560),
                child: _formCard(vw: vw, vh: vh, isWide: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout({required double vw, required double vh}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: vw * 0.02, top: vh * 0.005),
                child: const BotonAtras(),
              ),
            ),
          ),

          SizedBox(height: vh * 0.04),

          Center(
            child: SizedBox(
              width: vw * 0.88,
              child: _formCard(vw: vw, vh: vh, isWide: false),
            ),
          ),

          SizedBox(height: vh * 0.04),
        ],
      ),
    );
  }

  Widget _formCard({
    required double vw,
    required double vh,
    required bool isWide,
  }) {
    final double iconSize = isWide ? (vw * 0.06).clamp(60, 90)  : (vw * 0.18).clamp(64, 100);
    final double titleSize = isWide ? (vw * 0.024).clamp(20, 32) : (vw * 0.075).clamp(26, 38);
    final double descSize = isWide ? (vw * 0.010).clamp(12, 15) : (vw * 0.032).clamp(13, 16);
    final double buttonH = (vh * 0.065).clamp(44, 56);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        if (!isWide) ...[
          Center(
            child: Container(
              width: iconSize * 1.4,
              height: iconSize * 1.4,
              decoration: BoxDecoration(
                color: AppColors.primario.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(iconSize * 0.5),
              ),
              child: Icon(
                Icons.key_rounded,
                size: iconSize,
                color: AppColors.primario,
              ),
            ),
          ),

          SizedBox(height: vh * 0.030),

          Text(
            '¿Olvidaste tu\ncontraseña?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),

          SizedBox(height: vh * 0.016),

          Text(
            'No te preocupes, el ascenso continúa. Ingresa tu correo para recibir un enlace de recuperación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descSize,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),

          SizedBox(height: vh * 0.045),
        ],

        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Correo electrónico',
            style: TextStyle(
              fontSize: isWide ? (vw * 0.010).clamp(11, 14) : 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primario,
            ),
          ),
        ),

        TextfieldPers(
          controller: _emailCtrl,
          hint: 'tu@correo.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: vh * 0.035),

        Center(
          child: BotonesSombra(
            text: 'Enviar enlace',
            onPressed: () {},
            width: isWide ? (vw * 0.28).clamp(200, 300) : double.infinity,
            height: buttonH,
            backgroundColor: AppColors.primario,
          ),
        ),

        SizedBox(height: vh * 0.030),
      ],
    );
  }
}