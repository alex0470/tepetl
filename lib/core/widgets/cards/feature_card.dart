import 'package:flutter/material.dart';
import 'package:tepetl/core/theme/app_colors.dart';

class FeatureCardDark extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const FeatureCardDark({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF145A36),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(2, 2),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0E7146),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.secundario),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            desc,
            style: const TextStyle(
              color: AppColors.textoSecundario20,
            ),
          ),
        ],
      ),
    );
  }
}