import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class DetectionResultBox extends StatelessWidget {
  final String disease;       // clé brute dataset (ex: "Tomato___Early_blight")
  final String plantName;     // traduit selon la langue (ex: "Tomate")
  final String diseaseLabel;  // traduit selon la langue (ex: "Mildiou Précoce")
  final double confidence;

  const DetectionResultBox({
    super.key,
    required this.disease,
    required this.plantName,
    required this.diseaseLabel,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final surfaceAlt    = isDark ? AppColors.surfaceAlt    : AppColorsLight.surfaceAlt;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor    = isDark ? AppColors.error         : AppColorsLight.error;
    final gold          = isDark ? AppColors.gold          : AppColorsLight.gold;

    final confidencePct = (confidence * 100).toStringAsFixed(1);
    final isHealthy     = disease.contains('healthy');
    final barColor      = isHealthy
        ? primary
        : confidence > 0.7
            ? errorColor
            : gold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.biotech, color: primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              l.detectionResults,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // ── Plant name ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.eco_outlined, color: primary, size: 18),
              const SizedBox(width: 8),
              Text(
                l.plantName,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              const Spacer(),
              Text(
                plantName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          // ── Disease label ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isHealthy
                  ? primary.withOpacity(0.07)
                  : errorColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHealthy
                    ? primary.withOpacity(0.2)
                    : errorColor.withOpacity(0.2),
              ),
            ),
            child: Row(children: [
              Icon(
                isHealthy
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: isHealthy ? primary : errorColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  diseaseLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isHealthy ? primary : errorColor,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Confidence bar ───────────────────────────────────────
          Row(children: [
            Icon(Icons.bar_chart, color: textSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              l.confidence,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const Spacer(),
            Text(
              '$confidencePct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}