import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class DetectionResultBox extends StatelessWidget {
  final String disease;
  final double confidence;

  const DetectionResultBox({
    super.key,
    required this.disease,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePct = (confidence * 100).toStringAsFixed(1);
    final color = confidence > 0.7 ? AppColors.error : AppColors.gold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.biotech, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Detection Results',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Disease name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    disease,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Confidence bar
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              const Text('Confidence:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              Text(
                '$confidencePct%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}