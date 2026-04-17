import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tepetl/core/screens/autenticacion/seleccion_nivel.dart';
import 'package:tepetl/core/screens/inicio/landing_page.dart';
import 'package:tepetl/core/screens/inicio/onboarding.dart';
import 'package:tepetl/core/screens/principales/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Esperando estado de Firebase Auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LandingPage(); 
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(authSnapshot.data!.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const OnboardingScreen(); 
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
 
            final bool onboardingDone =
                data['onboardingCompletado'] as bool? ?? false;
            
            final bool nivelDone = 
                (data['nivel_seleccionado'] as bool? ?? false); 

            if (!onboardingDone) {
              return const OnboardingScreen();
            } else if (!nivelDone) {
              return const NivelSeleccionScreen();
            } else {
              final String rol = data['rol'] as String? ?? 'estudiante';
              return MainScreen(isAdmin: rol == 'admin');
            }
          },
        );
      },
    );
  }
}