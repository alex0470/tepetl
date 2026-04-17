import 'package:flutter/material.dart';

class DialogosUtils {
  // Función estática para poder llamarla desde cualquier lado sin crear una instancia
  static void mostrarSinCorazones(BuildContext context, {bool expulsarDePantalla = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Te has quedado sin corazones! 💔"),
        content: const Text("Debes esperar un poco para que se recarguen y puedas seguir practicando."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 1. Cierra el diálogo siempre
              
              if (expulsarDePantalla) {
                Navigator.pop(context); // 2. Saca al usuario del examen actual
              }
            },
            child: const Text("Entendido"),
          )
        ],
      ),
    );
  }
}