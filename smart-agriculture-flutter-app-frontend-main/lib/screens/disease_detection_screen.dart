import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(l.diseaseDetection),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textSecondary, size: 20),
            onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<DiseaseBloc, DiseaseState>(
        builder: (context, state) {
          if (state is DiseaseInitial) return _buildPickOptions(context, l, isDark);
          if (state is DiseaseLoading) return _buildLoading(state.selectedImage, l, isDark);
          if (state is DiseaseSuccess) return _buildResult(context, state, l, isDark);
          if (state is DiseaseError) return _buildError(context, state.error, l, isDark);
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPickOptions(BuildContext context, AppLocalizations l, bool isDark) {
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final gold = isDark ? AppColors.gold : AppColorsLight.gold;
    final bg = isDark ? AppColors.background : AppColorsLight.background;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
          child: const Center(child: Text('🔬', style: TextStyle(fontSize: 44))),
        ),
        const SizedBox(height: 20),
        Text(l.leafAnalysis, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary)),
        const SizedBox(height: 8),
        Text(l.leafAnalysisDesc, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSecondary, height: 1.6)),
        const SizedBox(height: 48),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(16)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.read<DiseaseBloc>().add(PickImageFromCameraEvent()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: bg.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.camera_alt_rounded, color: bg, size: 22)),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.takePhoto, style: TextStyle(fontWeight: FontWeight.w700, color: bg, fontSize: 15)),
                    Text(l.useCamera, style: TextStyle(fontSize: 12, color: bg.withOpacity(0.7))),
                  ]),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: bg.withOpacity(0.7)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: primary.withOpacity(0.4)), borderRadius: BorderRadius.circular(16)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.read<DiseaseBloc>().add(PickImageEvent()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.photo_library_rounded, color: primary, size: 22)),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.chooseGallery, style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 15)),
                    Text(l.browsePhotos, style: TextStyle(fontSize: 12, color: textSecondary)),
                  ]),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: textSecondary),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: gold.withOpacity(0.2))),
          child: Row(children: [
            const Text('💡', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Text(l.tipText, style: TextStyle(fontSize: 12, color: textSecondary, height: 1.5))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildLoading(File? image, AppLocalizations l, bool isDark) {
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final textMuted = isDark ? AppColors.textMuted : AppColorsLight.textMuted;
    final border = isDark ? AppColors.border : AppColorsLight.border;

    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (image != null)
        Container(height: 200, width: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(image, fit: BoxFit.cover))),
      const SizedBox(height: 28),
      CircularProgressIndicator(color: primary),
      const SizedBox(height: 16),
      Text(l.analysisInProgress, style: TextStyle(color: textSecondary, fontSize: 14)),
      const SizedBox(height: 4),
      Text(l.aiProcessing, style: TextStyle(color: textMuted, fontSize: 12)),
    ]));
  }

  Widget _buildResult(BuildContext context, DiseaseSuccess state, AppLocalizations l, bool isDark) {
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final bg = isDark ? AppColors.background : AppColorsLight.background;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        if (state.selectedImage != null)
          Container(height: 220, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(state.selectedImage!, fit: BoxFit.cover))),
        const SizedBox(height: 16),
        DetectionResultBox(disease: state.disease, confidence: state.confidence),
        const SizedBox(height: 16),
        AdviceBox(advice: state.advice),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(14)),
          child: ElevatedButton.icon(
            onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            icon: Icon(Icons.refresh_rounded, color: bg),
            label: Text(l.newAnalysis, style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }

  Widget _buildError(BuildContext context, String error, AppLocalizations l, bool isDark) {
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final bg = isDark ? AppColors.background : AppColorsLight.background;

    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 70, height: 70, decoration: BoxDecoration(color: errorColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Icon(Icons.error_outline_rounded, color: errorColor, size: 36)),
        const SizedBox(height: 16),
        Text(l.analysisFailed, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: 8),
        Text(error, textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
          style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
          child: Text(l.tryAgain, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
        ),
      ]),
    ));
  }
}