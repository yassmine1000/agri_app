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

  Future<void> _onPickImageFromGallery(PickImageEvent event, Emitter<DiseaseState> emit) async {
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

  Future<void> _onPickImageFromCamera(PickImageFromCameraEvent event, Emitter<DiseaseState> emit) async {
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

  Future<void> _onUploadImage(UploadImageEvent event, Emitter<DiseaseState> emit) async {
    emit(DiseaseLoading(event.image));
    try {
      final lang = await _getLanguage();
      print("LANGUE DETECTEE: '$lang'");
      final baseUrl = Config.baseUrl.replaceAll('/api', '');
      final apiUrl = baseUrl + '/predict?lang=' + lang;

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

      final disease    = response.data['disease'] as String;
      final confidence = (response.data['confidence'] as num).toDouble();
      final advice     = response.data['advice'] as String;

      // Sauvegarder dans l'historique
      try {
        final token = await PrefHelper.getToken();
        await Dio().post(
          '${Config.baseUrl}/history',
          data: {'disease': disease, 'confidence': confidence, 'advice': advice},
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          }),
        );
      } catch (e) {
        print('History save error: $e');
      }

      emit(DiseaseSuccess(event.image, disease, confidence, advice));
    } catch (e) {
      print("ERREUR DETECTION: $e");
      emit(DiseaseError("Échec de l'analyse: $e", selectedImage: event.image));
    }
  }
  
}
