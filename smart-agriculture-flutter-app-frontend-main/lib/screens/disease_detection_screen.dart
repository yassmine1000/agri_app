import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/bloc/disease/disease_bloc.dart';
import 'package:smart_agri_app/bloc/disease/disease_event.dart';
import 'package:smart_agri_app/bloc/disease/disease_state.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../utils/advice_box.dart';
import '../utils/detection_result_box.dart';

class DiseaseDetectionScreen extends StatelessWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiseaseBloc(),
      child: const DiseaseView(),
    );
  }
}

class DiseaseView extends StatelessWidget {
  const DiseaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Disease Detection'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DiseaseBloc, DiseaseState>(
        builder: (context, state) {
          if (state is DiseaseInitial) return _buildPickOptions(context);
          if (state is DiseaseLoading) return _buildLoading(state.selectedImage);
          if (state is DiseaseSuccess) return _buildResult(context, state);
          if (state is DiseaseError) return _buildError(context, state.error);
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPickOptions(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Icon header
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: Text('🔬', style: TextStyle(fontSize: 44))),
          ),
          const SizedBox(height: 20),
          const Text(
            'Leaf Analysis',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture or upload a leaf photo to detect plant diseases using AI.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),

          const SizedBox(height: 48),

          // Camera button
          _actionButton(
            context: context,
            icon: Icons.camera_alt_rounded,
            label: 'Take a Photo',
            subtitle: 'Use your camera',
            gradient: const [AppColors.primary, AppColors.cyan],
            onTap: () => context.read<DiseaseBloc>().add(PickImageFromCameraEvent()),
          ),

          const SizedBox(height: 14),

          // Gallery button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.read<DiseaseBloc>().add(PickImageEvent()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15)),
                          Text('Browse existing photos', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'For best results, take a clear photo of a single leaf in good lighting.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.background, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.background, fontSize: 15)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.background.withOpacity(0.7))),
                  ],
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.background.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(File? image) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null)
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(image, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 28),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('Analyzing leaf...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('AI is processing your image', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, DiseaseSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (state.selectedImage != null)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(state.selectedImage!, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 16),
          DetectionResultBox(disease: state.disease, confidence: state.confidence),
          const SizedBox(height: 16),
          AdviceBox(advice: state.advice),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded, color: AppColors.background),
              label: const Text('New Analysis', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Analysis Failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Try Again', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}