import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/autenticacion/seleccion_nivel.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';
import 'package:tepetl/core/widgets/inputs/textfield_pers.dart';
import 'package:tepetl/core/widgets/inputs/dropdown_pers.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  String? _idiomaSeleccionado = 'Español';
  int? _edadSeleccionada = 13;

  final List<String> _idiomas = ['Español', 'Náhuatl', 'Otro'];
  final List<int> _edades  = List.generate(83, (i) => i + 13);

  static const double _kBreakpoint = 700;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
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

  // Layout ancho
  Widget _wideLayout({required double vw, required double vh}) {
    final double formWidth = (vw * 0.45).clamp(400, 600);

    return Row(
      children: [
        // Panel izquierdo: logo
        Expanded(
          flex: 4,
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
              Center(child: _logoPanel(vw: vw, vh: vh, isWide: true)),
            ],
          ),
        ),

        // Panel derecho: formulario
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: vh * 0.05),
              child: SizedBox(
                width: formWidth,
                child: _formSection(vw: vw, vh: vh),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Estrecho
  Widget _narrowLayout({required double vw, required double vh}) {
    final double formWidth = vw * 0.80;

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

          Padding(
            padding: EdgeInsets.symmetric(vertical: vh * 0.03),
            child: _logoPanel(vw: vw, vh: vh, isWide: false),
          ),

          Center(
            child: SizedBox(
              width: formWidth,
              child: _formSection(vw: vw, vh: vh),
            ),
          ),

          SizedBox(height: vh * 0.04),
        ],
      ),
    );
  }

  // Panel logo
  Widget _logoPanel({
    required double vw,
    required double vh,
    required bool isWide,
  }) {

    final double logoSize = isWide ? vw * 0.13  : vw * 0.28;
    final double titleSize = isWide ? vw * 0.032 : vw * 0.09;
    final double subtitleSize = isWide ? vw * 0.012 : vw * 0.035;
    final double descSize = isWide ? vw * 0.010 : vw * 0.030;
    final double gapSm = vh * 0.008;
    final double gapMd = vh * 0.020;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo300.png',
          width: logoSize.clamp(80,  220),
          height: logoSize.clamp(80,  220),
        ),
        SizedBox(height: gapSm),
        Text(
          'TEPETL',
          style: TextStyle(
            color: AppColors.primario,
            fontSize: titleSize.clamp(24, 56),
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        SizedBox(height: gapSm * 0.5),
        Text(
          'APRENDE NÁHUATL',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: subtitleSize.clamp(11, 22),
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: gapMd),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: vw * 0.03),
          child: Text(
            'Únete a la comunidad y revitaliza el Náhuatl con el poder de la IA.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: descSize.clamp(10, 18),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Formulario
  Widget _formSection({required double vw, required double vh}) {
    final double fieldGap = vh * 0.018;
    final double buttonW = (vw * 1).clamp(200, 350);
    final double buttonH = (vh * 1).clamp(50, 50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Nombre completo'),
        TextfieldPers(
          controller: _nombreCtrl,
          hint: 'Ej. Juan Perez',
          prefixIcon: Icons.person_outline,
        ),

        SizedBox(height: fieldGap),
        _fieldLabel('Correo electrónico'),
        TextfieldPers(
          controller: _emailCtrl,
          hint: 'usuario@ejemplo.com',
          prefixIcon:   Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),

        SizedBox(height: fieldGap),
        _fieldLabel('Contraseña'),
        TextfieldPers(
          controller: _passCtrl,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscure: _obscurePass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: (vw * 0.018).clamp(16, 22),
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),

        SizedBox(height: fieldGap),
        _fieldLabel('Confirmar contraseña'),
        TextfieldPers(
          controller: _confirmPassCtrl,
          hint: '••••••••',
          prefixIcon: Icons.lock_outlined,
          obscure: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: (vw * 0.018).clamp(16, 22),
            ),
            onPressed: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),

        SizedBox(height: fieldGap),
        _fieldLabel('Idioma nativo'),
        DropdownPers<String>(
          value: _idiomaSeleccionado,
          items: _idiomas,
          label: (v) => v,
          prefixIcon: Icons.translate,
          onChanged: (v) => setState(() => _idiomaSeleccionado = v),
        ),

        SizedBox(height: fieldGap),
        _fieldLabel('Edad'),
        DropdownPers<int>(
          value: _edadSeleccionada,
          items: _edades,
          label: (v) => v.toString(),
          prefixIcon: Icons.numbers,
          onChanged: (v) => setState(() => _edadSeleccionada = v),
        ),

        SizedBox(height: vh * 0.035),

        Center(
          child: BotonesSombra(
            text:            'Crear Cuenta',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const NivelSeleccionScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            width: buttonW,
            height: buttonH,
            backgroundColor: AppColors.primario,
          ),
        ),

        SizedBox(height: vh * 0.018),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: (vw * 0.022).clamp(10, 13),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'Al registrarte, aceptas nuestros '),
              TextSpan(
                text:  'Términos de Servicio',
                style: TextStyle(
                  color: AppColors.secundario,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: ' y '),
              TextSpan(
                text:  'Política de Privacidad',
                style: TextStyle(
                  color: AppColors.secundario,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),

        SizedBox(height: vh * 0.020),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: (vw * 0.026).clamp(11, 15),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: '¿Ya tienes cuenta? '),
              TextSpan(
                text: 'Inicia sesión',
                style: TextStyle(
                  color: AppColors.secundario,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: vh * 0.010),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primario,
        ),
      ),
    );
  }
}