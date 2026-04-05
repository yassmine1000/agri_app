import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_agri_app/bloc/disease/disease_event.dart';
import 'package:smart_agri_app/config.dart';

import 'disease_state.dart';

class DiseaseBloc extends Bloc<DiseaseEvent, DiseaseState> {
  final ImagePicker picker = ImagePicker();

  DiseaseBloc() : super(DiseaseInitial()) {
    on<PickImageEvent>(_onPickImageFromGallery);
    on<PickImageFromCameraEvent>(_onPickImageFromCamera);
    on<UploadImageEvent>(_onUploadImage);
    on<ResetEvent>((event, emit) => emit(DiseaseInitial()));
  }

  Future<void> _onPickImageFromGallery(PickImageEvent event, Emitter<DiseaseState> emit) async {
    final pickedFile = await picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 70,
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
  final pickedFile = await picker.pickImage(
  source: ImageSource.camera,
  imageQuality: 70,
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
      // Utilise l'IP du backend depuis config.dart
      final baseUrl = Config.baseUrl.replaceAll('/api', '');
      final apiUrl = '$baseUrl/predict';

      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(event.image.path, filename: "image.jpg"),
      });

      final response = await Dio().post(apiUrl, data: formData);
      emit(DiseaseSuccess(
        event.image,
        response.data['disease'],
        response.data['confidence'],
        response.data['advice'],
      ));
    } catch (e) {
      emit(DiseaseError("Échec de l'analyse: $e", selectedImage: event.image));
    }
  }
}