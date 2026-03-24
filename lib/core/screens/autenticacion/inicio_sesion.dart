import 'package:flutter/material.dart';
import 'package:tepetl/core/screens/autenticacion/recuperar_contra.dart';
import 'package:tepetl/core/screens/lecciones/inicio.dart';
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
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;

  late final TabController _tabCtrl = TabController(length: 2, vsync: this);

  static const double _kBreakpoint = 700;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _tabCtrl.dispose();
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
    final double buttonH = (vh * 1).clamp(50,  50);
    final double fontSize = (vw * 0.022).clamp(11, 15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.secundario,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.secundario,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: fontSize),
          tabs: const [
            Tab(text: 'Usuario'),
            Tab(text: 'Administrador'),
          ],
        ),

        SizedBox(height: vh * 0.025),

        _fieldLabel('Correo electrónico'),
        TextfieldPers(
          controller: _emailCtrl,
          hint: 'usuario@ejemplo.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
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

        SizedBox(height: vh * 0.035),

        Center(
          child: BotonesSombra(
            text: 'Iniciar Sesión',
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const InicioScreen(),
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

        SizedBox(height: vh * 0.025),

        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: vw * 0.03),
              child: Text(
                'O inicia sesión con',
                style: TextStyle(
                  fontSize: (vw * 0.020).clamp(10, 13),
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),

        SizedBox(height: vh * 0.020),

        Row(
          children: [
            Expanded(
              child: BotonesSombra(
                text: 'Google',
                onPressed: () {},
                width: buttonW,
                height: buttonH,
                backgroundColor: AppColors.primario,
              ),
            ),
            SizedBox(width: vw * 0.03),
            Expanded(
              child: BotonesSombra(
                text: 'Apple',
                onPressed: () {},
                width: buttonW,
                height: buttonH,
                backgroundColor: AppColors.primario,
              ),
            ),
          ],
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
          fontSize:   12,
          fontWeight: FontWeight.w500,
          color: AppColors.primario,
        ),
      ),
    );
  }
}