import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_event.dart';
import 'package:smart_agri_app/bloc/weather/weather_state.dart';
import 'package:smart_agri_app/service/weather_api_service.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiService weatherApiService;

  WeatherBloc({required this.weatherApiService}) : super(WeatherInitial()) {
    on<FetchCurrentWeather>(_fetchCurrentWeather);
    on<FetchWeatherForecast>(_fetchWeatherForecast);
    on<FetchCurrentWeatherByCity>(_fetchCurrentWeatherByCity);
    on<FetchWeatherForecastByCity>(_fetchWeatherForecastByCity);
  }

  Future<void> _fetchCurrentWeather(FetchCurrentWeather event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weatherResponse = await weatherApiService.getCurrentWeather(event.lat, event.lon);
      emit(WeatherLoaded(weatherResponse: weatherResponse, isCurrentWeather: true));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

  Future<void> _fetchWeatherForecast(FetchWeatherForecast event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weatherResponse = await weatherApiService.getForecast(event.lat, event.lon, event.days);
      emit(WeatherLoaded(weatherResponse: weatherResponse, isCurrentWeather: false));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

  Future<void> _fetchCurrentWeatherByCity(FetchCurrentWeatherByCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weatherResponse = await weatherApiService.getCurrentWeatherByCity(event.city);
      emit(WeatherLoaded(weatherResponse: weatherResponse, isCurrentWeather: true));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }

  Future<void> _fetchWeatherForecastByCity(FetchWeatherForecastByCity event, Emitter<WeatherState> emit) async {
    emit(WeatherLoading());
    try {
      final weatherResponse = await weatherApiService.getForecastByCity(event.city, event.days);
      emit(WeatherLoaded(weatherResponse: weatherResponse, isCurrentWeather: false));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }
}