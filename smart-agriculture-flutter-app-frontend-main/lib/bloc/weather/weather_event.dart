abstract class WeatherEvent {}

class FetchCurrentWeather extends WeatherEvent {
  final double lat;
  final double lon;
  FetchCurrentWeather({required this.lat, required this.lon});
}

class FetchWeatherForecast extends WeatherEvent {
  final double lat;
  final double lon;
  final int days;
  FetchWeatherForecast({required this.lat, required this.lon, this.days = 3});
}

class FetchCurrentWeatherByCity extends WeatherEvent {
  final String city;
  FetchCurrentWeatherByCity({required this.city});
}

class FetchWeatherForecastByCity extends WeatherEvent {
  final String city;
  final int days;
  FetchWeatherForecastByCity({required this.city, this.days = 3});
}