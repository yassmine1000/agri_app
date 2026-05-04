import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/bloc/disease/disease_event.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'disease_state.dart';

class DiseaseBloc extends Bloc<DiseaseEvent, DiseaseState> {
  final ImagePicker picker = ImagePicker();

  DiseaseBloc() : super(DiseaseInitial()) {
    on<PickImageEvent>(_onPickImageFromGallery);
    on<PickImageFromCameraEvent>(_onPickImageFromCamera);
    on<UploadImageEvent>(_onUploadImage);
    on<ResetEvent>((event, emit) => emit(DiseaseInitial()));
  }

  Future<int> _getImageQuality() async {
    final prefs = await SharedPreferences.getInstance();
    final quality = prefs.getString('image_quality') ?? 'high';
    switch (quality) {
      case 'low':    return 40;
      case 'medium': return 65;
      case 'high':   return 90;
      default:       return 90;
    }
  }

  Future<String> _getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'EN';
  }

  Future<void> _onPickImageFromGallery(
      PickImageEvent event, Emitter<DiseaseState> emit) async {
    final quality = await _getImageQuality();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: quality,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      emit(DiseaseLoading(file));
      add(UploadImageEvent(file));
    }
  }

  Future<void> _onPickImageFromCamera(
      PickImageFromCameraEvent event, Emitter<DiseaseState> emit) async {
    final quality = await _getImageQuality();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: quality,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      emit(DiseaseLoading(file));
      add(UploadImageEvent(file));
    }
  }

  Future<void> _onUploadImage(
      UploadImageEvent event, Emitter<DiseaseState> emit) async {
    emit(DiseaseLoading(event.image));
    try {
      final lang = await _getLanguage();
      print("LANGUE DETECTEE: '$lang'");

      final apiUrl = '${Config.serverUrl}/predict?lang=$lang';

      final formData = FormData();
      formData.files.add(MapEntry(
        "image",
        await MultipartFile.fromFile(event.image.path, filename: "image.jpg"),
      ));
      formData.fields.add(MapEntry("lang", lang));

      final response = await Dio().post(
        apiUrl,
        data: formData,
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': 'true',
            'Accept-Language': lang,
          },
        ),
      );

      // ── Clé brute dataset (stable, langue-indépendant) ──────────
      final disease    = response.data['disease'] as String;
      final confidence = (response.data['confidence'] as num).toDouble();

      // ── Conseils dans les 3 langues ──────────────────────────────
      final adviceEn = (response.data['advice_en'] as String?)
          ?? response.data['advice'] as String;
      final adviceFr = (response.data['advice_fr'] as String?) ?? adviceEn;
      final adviceAr = (response.data['advice_ar'] as String?) ?? adviceEn;

      // ── Noms plante / maladie dans les 3 langues ─────────────────
      final plantNameEn = (response.data['plant_name_en'] as String?)
          ?? _fallbackPlant(disease);
      final plantNameFr = (response.data['plant_name_fr'] as String?) ?? plantNameEn;
      final plantNameAr = (response.data['plant_name_ar'] as String?) ?? plantNameEn;

      final diseaseLabelEn = (response.data['disease_label_en'] as String?)
          ?? _fallbackDisease(disease);
      final diseaseLabelFr = (response.data['disease_label_fr'] as String?) ?? diseaseLabelEn;
      final diseaseLabelAr = (response.data['disease_label_ar'] as String?) ?? diseaseLabelEn;

      // ── Valeurs dans la langue active (pour l'écran résultat) ────
      final advice       = lang == 'FR' ? adviceFr       : lang == 'AR' ? adviceAr       : adviceEn;
      final plantName    = lang == 'FR' ? plantNameFr    : lang == 'AR' ? plantNameAr    : plantNameEn;
      final diseaseLabel = lang == 'FR' ? diseaseLabelFr : lang == 'AR' ? diseaseLabelAr : diseaseLabelEn;

      // ── Sauvegarder dans l'historique (toutes les langues) ───────
      try {
        final token = await PrefHelper.getToken();
        await Dio().post(
          '${Config.baseUrl}/history',
          data: {
            'disease':          disease,
            'confidence':       confidence,
            'advice':           advice,
            'advice_en':        adviceEn,
            'advice_fr':        adviceFr,
            'advice_ar':        adviceAr,
            'plant_name_en':    plantNameEn,
            'plant_name_fr':    plantNameFr,
            'plant_name_ar':    plantNameAr,
            'disease_label_en': diseaseLabelEn,
            'disease_label_fr': diseaseLabelFr,
            'disease_label_ar': diseaseLabelAr,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          }),
        );
      } catch (e) {
        print('History save error: $e');
      }

      emit(DiseaseSuccess(
        event.image,
        disease,
        plantName,
        diseaseLabel,
        confidence,
        advice,
        lang,
      ));
    } catch (e) {
      print("ERREUR DETECTION: $e");
      emit(DiseaseError("Échec de l'analyse: $e", selectedImage: event.image));
    }
  }

  /// Fallback local si l'API ne retourne pas les champs traduits
  String _fallbackPlant(String disease) {
    final parts = disease.split('___');
    return parts.isNotEmpty ? parts[0].replaceAll('_', ' ') : disease;
  }

  String _fallbackDisease(String disease) {
    final parts = disease.split('___');
    return parts.length > 1
        ? parts[1].replaceAll('_', ' ')
        : disease.replaceAll('_', ' ');
  }
}