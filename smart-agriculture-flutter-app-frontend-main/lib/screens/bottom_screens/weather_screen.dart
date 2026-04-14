import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/bloc/weather/weather_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_state.dart';
import 'package:smart_agri_app/models/weather/weather_model.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../../bloc/weather/weather_event.dart';

class WeatherScreen extends StatefulWidget {
  final bool isDarkMode;
  const WeatherScreen({super.key, this.isDarkMode = true});

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
  void dispose() { _cityController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.background : AppColorsLight.background;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              style: TextStyle(color: textPrimary, fontSize: 14),
              onSubmitted: (_) => _searchWeather(),
              decoration: InputDecoration(
                hintText: l.searchCity, hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.location_city_outlined, color: textSecondary, size: 20),
                filled: true, fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(12)),
            child: ElevatedButton(
              onPressed: _searchWeather,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Icon(Icons.search, color: bg, size: 20),
            ),
          ),
        ]),
      ),
      Expanded(child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) return Center(child: CircularProgressIndicator(color: primary));
          if (state is WeatherLoaded) return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildCurrentWeather(state.weatherResponse, isDark, l, surface, border, primary, cyan, textPrimary, textSecondary),
              if (state.weatherResponse.forecast != null) ...[
                const SizedBox(height: 24),
                _buildForecast(state.weatherResponse.forecast!, isDark, l, surface, border, textPrimary, textSecondary),
              ],
            ]),
          );
          if (state is WeatherError) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_outlined, size: 60, color: textSecondary),
            const SizedBox(height: 12),
            Text('City not found', style: TextStyle(color: textSecondary)),
          ]));
          return Center(child: Text(l.searchCity, style: TextStyle(color: textSecondary)));
        },
      )),
    ]);
  }

  Widget _buildCurrentWeather(WeatherResponse weather, bool isDark, AppLocalizations l, Color surface, Color border, Color primary, Color cyan, Color textPrimary, Color textSecondary) {
    final iconUrl = 'http:${weather.currentWather.condition.icon}';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cyan.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.location_on, color: cyan, size: 16),
          const SizedBox(width: 4),
          Text('${weather.location.name}, ${weather.location.country}', style: TextStyle(color: cyan, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Image.network(iconUrl, width: 64, height: 64),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${weather.currentWather.tempC}°C', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: textPrimary)),
            Text(weather.currentWather.condition.text, style: TextStyle(fontSize: 14, color: textSecondary)),
          ]),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: isDark ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(children: [
              const Text('💧', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text('${weather.currentWather.humidity}%', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 13)),
              Text(l.humidity, style: TextStyle(fontSize: 11, color: textSecondary)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildForecast(Forecast forecast, bool isDark, AppLocalizations l, Color surface, Color border, Color textPrimary, Color textSecondary) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.daysForecast, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1.5)),
      const SizedBox(height: 12),
      ...forecast.forecastday.map((day) {
        final iconUrl = 'http:${day.day.condition.icon}';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
          child: Row(children: [
            Image.network(iconUrl, width: 36, height: 36),
            const SizedBox(width: 12),
            Expanded(child: Text(day.date, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 13))),
            Text(day.day.condition.text, style: TextStyle(fontSize: 11, color: textSecondary)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${day.day.maxtempC}°', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary, fontSize: 13)),
              Text('${day.day.mintempC}°', style: TextStyle(color: textSecondary, fontSize: 11)),
            ]),
          ]),
        );
      }),
    ]);
  }
}