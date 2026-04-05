import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/bloc/disease/disease_bloc.dart';
import 'package:smart_agri_app/bloc/disease/disease_event.dart';
import 'package:smart_agri_app/bloc/disease/disease_state.dart';

import '../utils/advice_box.dart';
import '../utils/detection_result_box.dart';

class DiseaseDetectionScreen extends StatelessWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiseaseBloc(),
      child: DiseaseView(),
    );
  }
}

class DiseaseView extends StatelessWidget {
  const DiseaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text("Disease Detection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
          )
        ],
      ),
      body: BlocBuilder<DiseaseBloc, DiseaseState>(
        builder: (context, state) {
          if (state is DiseaseInitial) {
            return _buildPickOptions(context);
          } else if (state is DiseaseLoading) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildImageBox(state.selectedImage),
                  ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: Colors.green),
                const SizedBox(height: 12),
                const Text('Analyse en cours...', style: TextStyle(color: Colors.grey)),
              ],
            );
          } else if (state is DiseaseSuccess) {
            return _buildResult(context, state);
          } else if (state is DiseaseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(state.error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPickOptions(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Analyser une feuille',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prenez une photo ou choisissez une image de la galerie pour détecter les maladies.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Bouton Caméra
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.read<DiseaseBloc>().add(PickImageFromCameraEvent()),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Prendre une photo', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton Galerie
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.read<DiseaseBloc>().add(PickImageEvent()),
                icon: const Icon(Icons.photo_library, color: Colors.green),
                label: const Text('Choisir depuis la galerie', style: TextStyle(color: Colors.green, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, DiseaseSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (state.selectedImage != null)
            _buildImageBox(state.selectedImage),
          const SizedBox(height: 16),
          DetectionResultBox(
            disease: state.disease,
            confidence: state.confidence,
          ),
          const SizedBox(height: 16),
          AdviceBox(advice: state.advice),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.read<DiseaseBloc>().add(ResetEvent()),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Nouvelle analyse', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBox(File? file) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: file != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.cover),
            )
          : const Center(child: Text("Aucune image sélectionnée")),
    );
  }
}