abstract class WeatherEvent {}

class FetchCurrentWeather extends WeatherEvent {
  final double lat;
  final double lon;
  final String lang;
  FetchCurrentWeather({required this.lat, required this.lon, this.lang = 'en'});
}

class FetchWeatherForecast extends WeatherEvent {
  final double lat;
  final double lon;
  final int days;
  final String lang;
  FetchWeatherForecast({required this.lat, required this.lon, this.days = 3, this.lang = 'en'});
}

class FetchCurrentWeatherByCity extends WeatherEvent {
  final String city;
  final String lang;
  FetchCurrentWeatherByCity({required this.city, this.lang = 'en'});
}

class FetchWeatherForecastByCity extends WeatherEvent {
  final String city;
  final int days;
  final String lang;
  FetchWeatherForecastByCity({required this.city, this.days = 3, this.lang = 'en'});
}