import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class AdviceBox extends StatelessWidget {
  final String advice;

  const AdviceBox({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline, color: AppColors.cyan, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Treatment Advice',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.cyan),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}