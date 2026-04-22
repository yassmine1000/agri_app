import 'dart:io';

abstract class DiseaseState {
  final File? selectedImage;
  const DiseaseState({this.selectedImage});
}

class DiseaseInitial extends DiseaseState {
  const DiseaseInitial({File? selectedImage}) : super(selectedImage: selectedImage);
}

class DiseaseLoading extends DiseaseState {
  const DiseaseLoading(File selectedImage) : super(selectedImage: selectedImage);
}

class DiseaseSuccess extends DiseaseState {
  final String disease;       // clé brute dataset — utilisée pour l'historique et les produits
  final String plantName;     // nom de la plante traduit selon la langue
  final String diseaseLabel;  // nom de la maladie traduit selon la langue
  final double confidence;
  final String advice;
  final String lang;          // 'EN' | 'FR' | 'AR' — pour les widgets de résultat

  const DiseaseSuccess(
    File selectedImage,
    this.disease,
    this.plantName,
    this.diseaseLabel,
    this.confidence,
    this.advice,
    this.lang,
  ) : super(selectedImage: selectedImage);
}

class DiseaseError extends DiseaseState {
  final String error;
  const DiseaseError(this.error, {File? selectedImage})
      : super(selectedImage: selectedImage);
}