import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/utils/custom_widgets.dart';
import '../disease_detection_screen.dart';
import '../fetilizer_form.dart';

class DetectionScreen extends StatelessWidget {
  final bool isDarkMode;
  const DetectionScreen({super.key, this.isDarkMode = true});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = isDarkMode;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final gold = isDark ? AppColors.gold : AppColorsLight.gold;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: primary.withOpacity(0.2))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.aiPowered, style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(l.plantIntelligence, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary)),
                const SizedBox(height: 6),
                Text(l.plantIntelligenceDesc, style: TextStyle(fontSize: 12, color: textSecondary, height: 1.5)),
              ])),
              const SizedBox(width: 12),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icons/agriscan_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          Text(l.tools, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 2)),
          const SizedBox(height: 14),
          FeatureCard(
            title: l.diseaseDetection,
            subtitle: l.diseaseDetectionDesc,
            emoji: '🔬',
            accentColor: primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseDetectionScreen())),
          ),
          const SizedBox(height: 12),
          FeatureCard(
            title: l.fertilizerRecommendation,
            subtitle: l.fertilizerRecommendationDesc,
            emoji: '⚗️',
            accentColor: gold,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FertilizerForm())),
          ),
          const SizedBox(height: 28),
          Row(children: [
            _statCard('95%', l.accuracy, primary, surface, border),
            const SizedBox(width: 12),
            _statCard('50+', l.diseases, cyan, surface, border),
            const SizedBox(width: 12),
            _statCard('24/7', l.available, gold, surface, border),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color, Color surface, Color border) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isDarkMode ? AppColors.textSecondary : AppColorsLight.textSecondary)),
      ]),
    ),
  );
}