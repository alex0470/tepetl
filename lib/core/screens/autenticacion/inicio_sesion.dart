import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';
import 'package:tepetl/core/widgets/botones/botones_sombra.dart';
import 'package:tepetl/core/widgets/botones/boton_atras.dart';
import 'package:tepetl/core/widgets/inputs/textfield_pers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _obscurePass = true;

  late final TabController _tabCtrl = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Mismas constantes que RegistroScreen ──────
  static const double _kBreakpoint   = 700;
  static const double _fieldsWide    = 550;
  static const double _fieldsNarrow  = 350;
  static const double _buttonWidth   = 250;

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

  // ─────────────────────────────────────────────
  //  LAYOUT ANCHO  — idéntico al de RegistroScreen
  // ─────────────────────────────────────────────
  Widget _wideLayout(BuildContext context) {
    return Row(
      children: [
        // Panel izquierdo: BotonAtras + logoPanel
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

        // Panel derecho: formulario
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

  // ─────────────────────────────────────────────
  //  LAYOUT ESTRECHO  — idéntico al de RegistroScreen
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  //  LOGO PANEL  — copiado 1:1 de RegistroScreen,
  //  solo cambia el texto descriptivo
  // ─────────────────────────────────────────────
  Widget _logoPanel({required bool large}) {
    final double logoSize     = large ? 200 : 110;
    final double titleSize    = large ? 48  : 36;
    final double subtitleSize = large ? 18  : 14;
    final double descSize     = large ? 16  : 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/logo300.png', width: logoSize, height: logoSize),
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
            'Bienvenido de vuelta. Continúa tu camino hacia el Náhuatl.',
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

  // ─────────────────────────────────────────────
  //  FORMULARIO
  // ─────────────────────────────────────────────
  Widget _formSection({required double buttonWidth}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // ── Tabs Usuario / Administrador ──────────
        TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.secundario,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.secundario,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          tabs: const [
            Tab(text: 'Usuario'),
            Tab(text: 'Administrador'),
          ],
        ),

        const SizedBox(height: 20),

        // ── Correo electrónico ────────────────────
        _fieldLabel('Correo electrónico'),
        TextfieldPers(
          controller: _emailCtrl,
          hint: 'usuario@ejemplo.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 14),

        // ── Contraseña + link Recuperar ───────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel('Contraseña'),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'Recuperar',
                  style: TextStyle(
                    fontSize: 12,
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
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),

        const SizedBox(height: 28),

        // ── Botón principal ───────────────────────
        Center(
          child: BotonesSombra(
            text: 'Iniciar Sesión',
            onPressed: () {},
            width: buttonWidth,
            height: 50,
            backgroundColor: AppColors.primario,
          ),
        ),

        const SizedBox(height: 14),

        // ── ¿No tienes cuenta? ────────────────────
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
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

        const SizedBox(height: 20),

        // ── Divider "O inicia sesión con" ─────────
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'O inicia sesión con',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),

        const SizedBox(height: 16),

        // ── Botones Google + Apple — mismo alto/ancho que el botón principal ──
        Row(
          children: [
            Expanded(
              child: BotonesSombra(
                text: 'Google',
                onPressed: () {},
                width: double.infinity,
                height: 50,
                backgroundColor: AppColors.primario,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonesSombra(
                text: 'Apple',
                onPressed: () {},
                width: double.infinity,
                height: 50,
                backgroundColor: AppColors.primario,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  FIELD LABEL  — copiado 1:1 de RegistroScreen
  // ─────────────────────────────────────────────
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