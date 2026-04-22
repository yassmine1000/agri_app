import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class AdviceBox extends StatelessWidget {
  final String advice;

  const AdviceBox({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cyan          = isDark ? AppColors.cyan          : AppColorsLight.cyan;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cyan.withOpacity(0.3)),
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
                  color: cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb_outline, color: cyan, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                l.treatmentAdvice,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}