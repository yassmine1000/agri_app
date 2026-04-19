import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:smart_agri_app/config.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Dio _dio = Dio();

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_handleLogin);
    on<RegisterEvent>(_handleRegister);
  }

  Future<void> _handleLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _dio.post('${Config.baseUrl}/auth/login', data: {
        'username': event.username,
        'password': event.password,
      });
      if (response.statusCode == 200) {
        await PrefHelper.saveLoginData(response.data['token'], response.data['user']);
        // Charger et sauvegarder le QR token après login
        try {
          final qrResponse = await _dio.get(
            '${Config.baseUrl}/auth/qr-token',
            options: Options(headers: {
              'Authorization': 'Bearer ${response.data['token']}',
              'ngrok-skip-browser-warning': 'true',
            }),
          );
          final qrToken = qrResponse.data['qr_token'];
          if (qrToken != null) await PrefHelper.saveQrToken(qrToken);
        } catch (_) {}
        emit(AuthSuccess(data: response.data));
      } else {
        emit(AuthFailure(error: 'Login failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Invalid credentials';
      emit(AuthFailure(error: msg));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _handleRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _dio.post(
        '${Config.baseUrl}/auth/register',
        data: event.userDate,
      );
      if (response.statusCode == 201) {
        final qrToken = response.data['qr_token'];
        if (qrToken != null) await PrefHelper.saveQrToken(qrToken);
        emit(AuthSuccess(data: response.data));
      } else {
        emit(AuthFailure(error: 'Registration failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed';
      emit(AuthFailure(error: msg));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}