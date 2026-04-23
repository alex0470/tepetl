import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';
import 'package:tepetl/core/widgets/inputs/textfield_pers.dart';
import 'package:tepetl/core/widgets/inputs/dropdown_pers.dart';
import 'package:tepetl/core/services/auth_service.dart';
import 'package:tepetl/core/services/firestore_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  final _nombreCtrl       = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passCtrl         = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  String? _idiomaSeleccionado = 'Español';
  int?    _edadSeleccionada   = 13;

  String? _errorNombre;
  String? _errorEmail;
  String? _errorPass;
  String? _errorConfirm;

  final List<String> _idiomas = ['Español', 'Náhuatl', 'Otro'];
  final List<int>    _edades  = List.generate(83, (i) => i + 13);

  static const double _kBreakpoint = 700;

  //Validadores
  bool get _passHasMin8    => _passCtrl.text.length >= 8;
  bool get _passHasUpper   => _passCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _passHasLower   => _passCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _passHasNumber  => _passCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _passHasSpecial => _passCtrl.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

  bool _isValidEmail(String email) {
    final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    return re.hasMatch(email);
  }

  String? _validateNombre(String v) {
    if (v.isEmpty) return 'El nombre es requerido';
    if (v.length < 2) return 'Ingresa tu nombre completo';
    return null;
  }

  String? _validateEmail(String v) {
    if (v.isEmpty) return 'El correo es requerido';
    if (!_isValidEmail(v)) return 'Ingresa un correo válido (ej. usuario@dominio.com)';
    return null;
  }

  String? _validatePass(String v) {
    if (v.isEmpty)        return 'La contraseña es requerida';
    if (!_passHasMin8)    return 'Mínimo 8 caracteres';
    if (!_passHasUpper)   return 'Agrega al menos una mayúscula';
    if (!_passHasLower)   return 'Agrega al menos una minúscula';
    if (!_passHasNumber)  return 'Agrega al menos un número';
    if (!_passHasSpecial) return 'Agrega al menos un carácter especial (!@#\$%...)';
    return null;
  }

  String? _validateConfirm(String v) {
    if (v.isEmpty) return 'Confirma tu contraseña';
    if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  bool _validateAll() {
    setState(() {
      _errorNombre  = _validateNombre(_nombreCtrl.text.trim());
      _errorEmail   = _validateEmail(_emailCtrl.text.trim());
      _errorPass    = _validatePass(_passCtrl.text);
      _errorConfirm = _validateConfirm(_confirmPassCtrl.text);
    });
    return _errorNombre == null &&
        _errorEmail   == null &&
        _errorPass    == null &&
        _errorConfirm == null;
  }

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

  Widget _wideLayout({required double vw, required double vh}) {
    final double formWidth = (vw * 0.45).clamp(400, 600);
    return Row(
      children: [
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

  Widget _logoPanel({
    required double vw,
    required double vh,
    required bool isWide,
  }) {
    final double logoSize     = isWide ? vw * 0.13  : vw * 0.28;
    final double titleSize    = isWide ? vw * 0.032 : vw * 0.09;
    final double subtitleSize = isWide ? vw * 0.012 : vw * 0.035;
    final double descSize     = isWide ? vw * 0.010 : vw * 0.030;
    final double gapSm = vh * 0.008;
    final double gapMd = vh * 0.020;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo300.png',
          width:  logoSize.clamp(80, 220),
          height: logoSize.clamp(80, 220),
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

  Widget _formSection({required double vw, required double vh}) {
    final double fieldGap = vh * 0.018;
    final double buttonW  = (vw * 1).clamp(200, 350);
    final double buttonH  = (vh * 1).clamp(50, 50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Nombre completo'),
        TextfieldPers(
          controller: _nombreCtrl,
          hint: 'Ej. Juan Perez',
          prefixIcon: Icons.person_outline,
          onChanged: (_) => setState(() => _errorNombre = null),
        ),
        _errorWidget(_errorNombre),

        SizedBox(height: fieldGap),

        _fieldLabel('Correo electrónico'),
        TextfieldPers(
          controller: _emailCtrl,
          hint: 'usuario@ejemplo.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() => _errorEmail = null),
        ),
        _errorWidget(_errorEmail),

        SizedBox(height: fieldGap),

        _fieldLabel('Contraseña'),
        TextfieldPers(
          controller: _passCtrl,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscure: _obscurePass,
          onChanged: (_) => setState(() {
            _errorPass    = null;
            _errorConfirm = null;
          }),
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
        _errorWidget(_errorPass),
        const SizedBox(height: 8),
        _passRequirements(),

        SizedBox(height: fieldGap),

        _fieldLabel('Confirmar contraseña'),
        TextfieldPers(
          controller: _confirmPassCtrl,
          hint: '••••••••',
          prefixIcon: Icons.lock_outlined,
          obscure: _obscureConfirm,
          onChanged: (_) => setState(() => _errorConfirm = null),
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
        _errorWidget(_errorConfirm),

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
            text: 'Crear Cuenta',
            onPressed: () async {
              if (!_validateAll()) return;

              final nombre = _nombreCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              final pass = _passCtrl.text;

              final (user, error) = await _auth.register(email, pass);

              if (!mounted) return;

              if (user != null) {
                await _firestore.saveUser(user.uid, email);
                await _firestore.updateUser(user.uid, {
                  'nombre': nombre,
                  'idioma': _idiomaSeleccionado,
                  'edad': _edadSeleccionada,
                  'rol': 'estudiante',
                  'onboardingCompletado': false,
                  'nivel_seleccionado': false,
                });

                if (!mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                setState(() => _errorEmail = error ?? 'Error al registrar usuario');
              }
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

        SizedBox(height: vh * 0.020),

        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: (vw * 0.026).clamp(11, 15),
                color: ColorScheme.of(context).onSurface,
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
        ),

        SizedBox(height: vh * 0.010),
      ],
    );
  }

  Widget _passRequirements() {
    if (_passCtrl.text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reqRow('Mínimo 8 caracteres', _passHasMin8),
        _reqRow('Al menos una mayúscula (A-Z)', _passHasUpper),
        _reqRow('Al menos una minúscula (a-z)', _passHasLower),
        _reqRow('Al menos un número (0-9)', _passHasNumber),
        _reqRow('Al menos un carácter especial (!@#\$...)', _passHasSpecial),
      ],
    );
  }

  Widget _reqRow(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 14,
            color: ok ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: ok ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String? msg) {
    if (msg == null) return const SizedBox(height: 2);
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, bottom: 2),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 13, color: Color(0xFFD32F2F)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              msg,
              style: const TextStyle(fontSize: 11, color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
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