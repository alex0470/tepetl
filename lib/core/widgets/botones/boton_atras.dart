import 'package:flutter/material.dart';

class BotonAtras extends StatelessWidget {
  final VoidCallback? onPressed;

  const BotonAtras({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}