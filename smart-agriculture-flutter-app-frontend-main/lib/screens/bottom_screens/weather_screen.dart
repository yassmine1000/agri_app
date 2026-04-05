import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_state.dart';
import 'package:smart_agri_app/models/weather/weather_model.dart';
import '../../bloc/weather/weather_event.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  void _searchWeather() {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;
    context.read<WeatherBloc>().add(FetchCurrentWeatherByCity(city: city));
    context.read<WeatherBloc>().add(FetchWeatherForecastByCity(city: city, days: 3));
  }

  @override
  void initState() {
    super.initState();
    _cityController.text = 'Tunis';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchWeather();
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche ville
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Entrez une ville...',
                    prefixIcon: const Icon(Icons.location_city, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _searchWeather(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchWeather,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ],
          ),
        ),

        // Résultat météo
        Expanded(
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              } else if (state is WeatherLoaded) {
                final weatherResponse = state.weatherResponse;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentWeather(weatherResponse),
                      if (weatherResponse.forecast != null)
                        ..._buildForecast(weatherResponse.forecast!),
                    ],
                  ),
                );
              } else if (state is WeatherError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(state.message, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return const Center(
                child: Text('Recherchez une ville pour voir la météo'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather(WeatherResponse weather) {
    final iconUrl = 'http:${weather.currentWather.condition.icon}';
    return Card(
      color: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.network(iconUrl, width: 60, height: 60, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.location.name}, ${weather.location.country}',
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${weather.currentWather.tempC}°C',
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.currentWather.condition.text}',
                    style: TextStyle(fontSize: 16, color: Colors.yellow.shade200),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Humidité: ${weather.currentWather.humidity}%',
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildForecast(Forecast forecast) {
    return [
      const SizedBox(height: 24),
      const Text('3-days Forecast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...forecast.forecastday.map((day) {
        final iconUrl = 'http:${day.day.condition.icon}';
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            leading: Image.network(iconUrl, width: 40, height: 40),
            title: Text('${day.date}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text('Max: ${day.day.maxtempC}°C, Min: ${day.day.mintempC}°C', style: const TextStyle(fontSize: 11)),
            trailing: Text('${day.day.condition.text}', style: const TextStyle(fontSize: 9)),
          ),
        );
      }),
    ];
  }
}