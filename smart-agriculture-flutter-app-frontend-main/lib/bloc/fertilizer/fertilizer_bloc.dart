import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/bloc/fertilizer/fertilizer_event.dart';
import 'package:smart_agri_app/bloc/fertilizer/fertilizer_state.dart';
import 'package:smart_agri_app/config.dart';

class FertilizerBloc extends Bloc<FertilizerEvent, FertilizerState> {
  final Dio dio = Dio();

  FertilizerBloc() : super(FertilizerInitial()) {
    on<FetchDropdowns>(_onFetchDropdown);
    on<GetRecommendation>(_onGetRecommendation);
  }

  Future<void> _onFetchDropdown(
      FetchDropdowns event, Emitter<FertilizerState> emit) async {
    emit(FertilizerLoading());
    try {
      final baseUrl = Config.baseUrl.replaceAll('/api', '');
      final response = await dio.get(
        '$baseUrl/api/dropdowns',
        options: Options(headers: {'ngrok-skip-browser-warning': 'true'}),
      );
      emit(FertilizerDropdownsLoaded(
        List<String>.from(response.data['crops']),
        List<String>.from(response.data['stages']),
        List<String>.from(response.data['soilTypes']),
      ));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'dropdown_error';
      emit(FertilizerError('dropdown_error: $msg'));
    } catch (e) {
      emit(FertilizerError('dropdown_error: $e'));
    }
  }

  Future<void> _onGetRecommendation(
      GetRecommendation event, Emitter<FertilizerState> emit) async {
    emit(FertilizerLoading());
    try {
      final baseUrl = Config.baseUrl.replaceAll('/api', '');
      final response = await dio.post(
        '$baseUrl/predict_fertilizer',
        data: event.formData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
          // Don't throw on error status codes — handle manually
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      if (response.statusCode == 200) {
        final rec = response.data['recommendation'];
        if (rec == null || rec.toString().trim().isEmpty) {
          emit(FertilizerError('recommendation_error'));
        } else {
          emit(FertilizerRecommendationSuccess(rec.toString()));
        }
      } else {
        // Log server error for debugging
        final serverErr = response.data?['error']?.toString() ?? 'status ${response.statusCode}';
        print('Fertilizer API error: $serverErr');
        emit(FertilizerError('recommendation_error'));
      }
    } on DioException catch (e) {
      print('Fertilizer DioException: ${e.message}');
      emit(FertilizerError('recommendation_error'));
    } catch (e) {
      print('Fertilizer unknown error: $e');
      emit(FertilizerError('recommendation_error'));
    }
  }
}