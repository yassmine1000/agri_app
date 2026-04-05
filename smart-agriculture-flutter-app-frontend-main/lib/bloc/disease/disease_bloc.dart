
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_agri_app/bloc/disease/disease_event.dart';

import 'disease_state.dart';

class DiseaseBloc extends Bloc<DiseaseEvent, DiseaseState> {
  final ImagePicker picker = ImagePicker();

  DiseaseBloc() : super(DiseaseInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<UploadImageEvent>(_onUploadImage);
    on<ResetEvent>((event, emit) => emit(DiseaseInitial()));
  }


  Future<void> _onPickImage(PickImageEvent event, Emitter<DiseaseState> emit) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      final file = File(pickedFile.path);
      emit(DiseaseLoading(file));
      add(UploadImageEvent(file));
    }
  }

  Future<void> _onUploadImage(UploadImageEvent event, Emitter<DiseaseState> emit) async {
    emit(DiseaseLoading(event.image));
    try{
      String apiUrl = "http://192.168.100.35:6070/predict";
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

    } catch(e){
      emit(DiseaseError("Failed to process image: $e", selectedImage: event.image));
    }
  }
}