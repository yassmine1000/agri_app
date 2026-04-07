import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import 'package:smart_agri_app/utils/custom_widgets.dart';
import '../disease_detection_screen.dart';
import '../fetilizer_form.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI-Powered',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Plant Intelligence',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Detect diseases and optimize your crops with advanced AI analysis.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('🤖', style: TextStyle(fontSize: 30))),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'TOOLS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 2),
          ),
          const SizedBox(height: 14),

          FeatureCard(
            title: 'Disease Detection',
            subtitle: 'Upload or capture a leaf image to identify diseases and get treatment advice instantly.',
            emoji: '🔬',
            accentColor: AppColors.primary,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseDetectionScreen())),
          ),

          const SizedBox(height: 12),

          FeatureCard(
            title: 'Fertilizer Recommendation',
            subtitle: 'Get personalized fertilizer advice based on your crop type and soil conditions.',
            emoji: '⚗️',
            accentColor: AppColors.gold,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FertilizerForm())),
          ),

          const SizedBox(height: 28),

          // Stats row
          Row(
            children: [
              _statCard('95%', 'Accuracy', AppColors.primary),
              const SizedBox(width: 12),
              _statCard('50+', 'Diseases', AppColors.cyan),
              const SizedBox(width: 12),
              _statCard('24/7', 'Available', AppColors.gold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}