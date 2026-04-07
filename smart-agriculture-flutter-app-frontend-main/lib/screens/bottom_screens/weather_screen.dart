import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_state.dart';
import 'package:smart_agri_app/models/weather/weather_model.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchWeather());
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
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  onSubmitted: (_) => _searchWeather(),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.textSecondary, size: 20),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _searchWeather,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.search, color: AppColors.background, size: 20),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              } else if (state is WeatherLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCurrentWeather(state.weatherResponse),
                      if (state.weatherResponse.forecast != null) ...[
                        const SizedBox(height: 24),
                        _buildForecast(state.weatherResponse.forecast!),
                      ],
                    ],
                  ),
                );
              } else if (state is WeatherError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 60, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text('City not found or API error', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return const Center(
                child: Text('Search a city to see weather', style: TextStyle(color: AppColors.textSecondary)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeather(WeatherResponse weather) {
    final iconUrl = 'http:${weather.currentWather.condition.icon}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.cyan, size: 16),
              const SizedBox(width: 4),
              Text(
                '${weather.location.name}, ${weather.location.country}',
                style: const TextStyle(color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.network(iconUrl, width: 64, height: 64),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.currentWather.tempC}°C',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    weather.currentWather.condition.text,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weatherStat('💧', 'Humidity', '${weather.currentWather.humidity}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildForecast(Forecast forecast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('3-DAY FORECAST',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        ...forecast.forecastday.map((day) {
          final iconUrl = 'http:${day.day.condition.icon}';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Image.network(iconUrl, width: 36, height: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(day.date,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                ),
                Text(day.day.condition.text,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${day.day.maxtempC}°', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
                    Text('${day.day.mintempC}°', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}