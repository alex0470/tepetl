import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTRO — devuelve (user, errorMessage)
  Future<(User?, String?)> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (credential.user, null);
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use'  => 'Este correo ya está registrado.',
        'invalid-email'         => 'El correo no es válido.',
        'weak-password'         => 'La contraseña debe tener al menos 6 caracteres.',
        'operation-not-allowed' => 'El registro con email/contraseña no está habilitado.',
        _                       => 'Error: ${e.message}',
      };
      return (null, msg);
    } catch (e) {
      return (null, 'Error inesperado: $e');
    }
  }

  // LOGIN — devuelve (user, errorMessage)
  Future<(User?, String?)> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (credential.user, null);
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found'   => 'No existe cuenta con ese correo.',
        'wrong-password'   => 'Contraseña incorrecta.',
        'invalid-email'    => 'El correo no es válido.',
        'user-disabled'    => 'Esta cuenta ha sido deshabilitada.',
        _                  => 'Error: ${e.message}',
      };
      return (null, msg);
    } catch (e) {
      return (null, 'Error inesperado: $e');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}