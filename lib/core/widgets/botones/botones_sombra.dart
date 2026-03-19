import 'package:flutter/material.dart';

class BotonesSombra extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final double width;
  final double height;

  final Color? backgroundColor;
  final Color? textColor;

  final FontWeight fontWeight;
  final double fontSize;

  final double borderRadius;

  final bool hasShadow;

  const BotonesSombra({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 200,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.fontWeight = FontWeight.bold,
    this.fontSize = 16,
    this.borderRadius = 16,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(2, 2),
                ),
        ] : [],
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}