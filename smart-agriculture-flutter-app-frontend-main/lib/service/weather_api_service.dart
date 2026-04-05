import 'package:dio/dio.dart';
import 'package:smart_agri_app/models/weather/weather_model.dart';

class WeatherApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.weatherapi.com/v1',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));

  final String _apiKey = '031aa34fff274d6390800546260504'; // remplace par ta vraie clé

  Future<WeatherResponse> getCurrentWeather(double lat, double lon) async {
    try {
      final res = await _dio.get('/current.json', queryParameters: {
        'key': _apiKey,
        'q': '$lat,$lon',
      });
      return WeatherResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception('Failed to load weather data: ${e.message}');
    }
  }

  Future<WeatherResponse> getCurrentWeatherByCity(String city) async {
    try {
      final res = await _dio.get('/current.json', queryParameters: {
        'key': _apiKey,
        'q': city,
      });
      return WeatherResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception('Ville introuvable: ${e.message}');
    }
  }

  Future<WeatherResponse> getForecast(double lat, double lon, int days) async {
    try {
      final res = await _dio.get('/forecast.json', queryParameters: {
        'key': _apiKey,
        'q': '$lat,$lon',
        'days': days,
        'alerts': 'yes',
      });
      return WeatherResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception('Failed to load forecast: ${e.message}');
    }
  }

  Future<WeatherResponse> getForecastByCity(String city, int days) async {
    try {
      final res = await _dio.get('/forecast.json', queryParameters: {
        'key': _apiKey,
        'q': city,
        'days': days,
        'alerts': 'yes',
      });
      return WeatherResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception('Ville introuvable: ${e.message}');
    }
  }
}