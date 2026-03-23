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
  final List<int> _edades = List.generate(83, (i) => i + 13);

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  static const double _kBreakpoint = 700;
  static const double _fieldsWide = 550;
  static const double _fieldsNarrow = 350;
  static const double _buttonWidth = 250;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= _kBreakpoint;
          return isWide ? _wideLayout(context) : _narrowLayout(context);
        },
      ),
    );
  }

  Widget _wideLayout(BuildContext context) {

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
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: BotonAtras(),
                    ),
                  ),
                ),
                Center(child: _logoPanel(large: true)),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SizedBox(
                width: _fieldsWide,
                child: _formSection(buttonWidth: _buttonWidth),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // pantallas estrechas
  Widget _narrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: const Padding(
              padding: EdgeInsets.only(left: 8, top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BotonAtras(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _logoPanel(large: false),
          ),

          Center(
            child: SizedBox(
              width: _fieldsNarrow,
              child: _formSection(buttonWidth: _buttonWidth),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // parte logo
  Widget _logoPanel({required bool large}) {
    final double logoSize = large ? 200 : 110;
    final double titleSize = large ? 48 : 36;
    final double subtitleSize = large ? 18 : 14;
    final double descSize = large ? 16 : 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/logo300.png", width: logoSize, height: logoSize),
        const SizedBox(height: 14),
        Text(
          'TEPETL',
          style: TextStyle(
            color: AppColors.primario,
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'APRENDE NÁHUATL',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Únete a la comunidad y revitaliza el Náhuatl con el poder de la IA.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: descSize,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // formulario
  Widget _formSection({required double buttonWidth}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Nombre completo'),
        TextfieldPers(
          controller: _nombreCtrl,
          hint: 'Ej. Juan Perez',
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 14),
        _fieldLabel('Correo electrónico'),
        TextfieldPers(
          controller: _emailCtrl,
          hint: 'usuario@ejemplo.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 14),
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
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),

        const SizedBox(height: 14),
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
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),

        const SizedBox(height: 14),
        _fieldLabel('Idioma nativo'),
        DropdownPers<String>(
          value: _idiomaSeleccionado,
          items: _idiomas,
          label: (v) => v,
          prefixIcon: Icons.translate,
          onChanged: (v) => setState(() => _idiomaSeleccionado = v),
        ),

        const SizedBox(height: 14),
        _fieldLabel('Edad'),
        DropdownPers<int>(
          value: _edadSeleccionada,
          items: _edades,
          label: (v) => v.toString(),
          prefixIcon: Icons.numbers,
          onChanged: (v) => setState(() => _edadSeleccionada = v),
        ),

        const SizedBox(height: 28),

        Center(
          child: BotonesSombra(
            text: "Crear Cuenta",
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const NivelSeleccionScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            width: 250,
            height: 50,
            backgroundColor: AppColors.primario,
          ),
        ),

        const SizedBox(height: 14),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
            children: [
              const TextSpan(text: 'Al registrarte, aceptas nuestros '),
              TextSpan(
                text: 'Términos de Servicio',
                style: TextStyle(
                  color: AppColors.secundario,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: ' y '),
              TextSpan(
                text: 'Política de Privacidad',
                style: TextStyle(
                  color: AppColors.secundario,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
 
        const SizedBox(height: 16),
 
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
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
        const SizedBox(height: 8),
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