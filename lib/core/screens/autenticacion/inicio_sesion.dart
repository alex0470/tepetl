import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tepetl/core/screens/autenticacion/recuperar_contra.dart';
import 'package:tepetl/core/screens/autenticacion/registro.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';
import 'package:tepetl/core/widgets/inputs/textfield_pers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading = false; // Para el estado de carga

  // Variables para los mensajes de error
  String? _emailError;
  String? _passError;
  String? _generalError;

  static const double _kBreakpoint = 700;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Lógica de validación
  bool _validarCampos() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passError = null;
      _generalError = null;

      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text;

      if (email.isEmpty) {
        _emailError = 'El correo es requerido.';
        isValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Ingresa un correo electrónico válido.';
        isValid = false;
      }

      if (pass.isEmpty) {
        _passError = 'La contraseña es requerida.';
        isValid = false;
      }
    });
    return isValid;
  }

  // Lógica de inicio de sesión con Firebase
  Future<void> _iniciarSesion() async {
    if (!_validarCampos()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (mounted) {
      // Quita la pantalla de login para que se vea lo que el AuthWrapper decidió mostrar
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _generalError = 'Credenciales incorrectas. Verifica tus datos.';
        } else if (e.code == 'user-disabled') {
          _generalError = 'Esta cuenta ha sido deshabilitada.';
        } else {
          _generalError = 'Ocurrió un error. Inténtalo más tarde.';
        }
      });
    } catch (e) {
      setState(() {
        _generalError = 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    final double formWidth = vw * 0.88;

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
    final double logoSize = isWide ? vw * 0.13 : vw * 0.28;
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
          width: logoSize.clamp(80, 220),
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
            'Bienvenido de vuelta. Continúa tu camino hacia el Náhuatl.',
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
    final colorScheme = Theme.of(context).colorScheme;
    final double fieldGap = vh * 0.018;
    final double buttonW = (vw * 1).clamp(250, 300);
    final double buttonH = (vh * 1).clamp(50, 50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Correo electrónico'),
        TextfieldPers(
          controller: _emailCtrl,
          hint: 'usuario@ejemplo.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        // Error de correo
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _emailError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        SizedBox(height: fieldGap),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel('Contraseña'),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) => const RecuperarContraScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Text(
                  'Recuperar',
                  style: TextStyle(
                    fontSize: (vw * 0.020).clamp(10, 13),
                    fontWeight: FontWeight.w500,
                    color: AppColors.secundario,
                  ),
                ),
              ),
            ),
          ],
        ),
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
        // Error de contraseña
        if (_passError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _passError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        SizedBox(height: vh * 0.035),

        // Error general (Credenciales incorrectas)
        if (_generalError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _generalError!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

        Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : BotonesSombra(
                  text: 'Iniciar Sesión',
                  onPressed: _iniciarSesion,
                  width: buttonW,
                  height: buttonH,
                  backgroundColor: AppColors.primario,
                ),
        ),

        SizedBox(height: vh * 0.018),

        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroScreen()));
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: (vw * 0.026).clamp(11, 15),
                color: colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: '¿No tienes cuenta? '),
                TextSpan(
                  text: 'Crea una',
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