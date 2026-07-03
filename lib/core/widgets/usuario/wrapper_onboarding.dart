import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tepetl/core/screens/autenticacion/inicio_sesion.dart';
import 'package:tepetl/core/screens/autenticacion/seleccion_nivel.dart';
import 'package:tepetl/core/screens/inicio/landing_page.dart';
import 'package:tepetl/core/screens/inicio/onboarding.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Tab que se mostrará en MainScreen al salir del onboarding.
  // 0 = Cultura, 2 = Inicio (default)
  int _initialTab = 2;

  // Cached Firestore stream — recreated only when the UID changes.
  Stream<DocumentSnapshot>? _userStream;
  String? _cachedUid;

  void _irACulturaAlSalir() {
    setState(() => _initialTab = 0);
  }

  void _updateUserStream(String uid) {
    if (uid != _cachedUid) {
      _cachedUid = uid;
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          if (kIsWeb) {
            return const LandingPage();
          } else {
            return const LoginScreen();
          }
        }

        _updateUserStream(authSnapshot.data!.uid);

        return StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return OnboardingScreen(onVerArticulos: _irACulturaAlSalir);
            }

            final data =
                userSnapshot.data!.data() as Map<String, dynamic>? ?? {};

            final bool onboardingDone =
                data['onboardingCompletado'] as bool? ?? false;
            final bool nivelDone =
                data['nivel_seleccionado'] as bool? ?? false;
            final String rol = data['rol'] as String? ?? 'estudiante';

            if (!onboardingDone) {
              // MainScreen de fondo + overlay del onboarding
              return Stack(
                children: [
                  MainScreen(
                    isAdmin: rol == 'admin',
                    initialIndex: _initialTab,
                  ),
                  OnboardingScreen(onVerArticulos: _irACulturaAlSalir),
                ],
              );
            } else if (!nivelDone) {
              return const NivelSeleccionScreen();
            } else {
              return MainScreen(
                isAdmin: rol == 'admin',
                initialIndex: _initialTab,
              );
            }
          },
        );
      },
    );
  }
}
