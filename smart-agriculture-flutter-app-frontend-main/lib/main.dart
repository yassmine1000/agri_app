import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_agri_app/bloc/auth/auth_bloc.dart';
import 'package:smart_agri_app/bloc/fertilizer/fertilizer_bloc.dart';
import 'package:smart_agri_app/bloc/market/price_bloc.dart';
import 'package:smart_agri_app/bloc/weather/weather_bloc.dart';
import 'package:smart_agri_app/screens/splash_screen.dart';
import 'package:smart_agri_app/service/agmarknet_service.dart';
import 'package:smart_agri_app/service/weather_api_service.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'EN';
  final isDark = prefs.getBool('is_dark_mode') ?? true;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => FertilizerBloc()),
        BlocProvider(create: (_) => PriceBloc(apiService: AgmarknetService())),
        BlocProvider(create: (_) => WeatherBloc(weatherApiService: WeatherApiService())),
      ],
      child: MyApp(initialLang: savedLang, initialDark: isDark),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialLang;
  final bool initialDark;
  const MyApp({super.key, required this.initialLang, required this.initialDark});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale _locale;
  late ValueNotifier<bool> isDarkNotifier;

  @override
  void initState() {
    super.initState();
    _locale = _langToLocale(widget.initialLang);
    isDarkNotifier = ValueNotifier(widget.initialDark);
  }

  @override
  void dispose() {
    isDarkNotifier.dispose();
    super.dispose();
  }

  Locale _langToLocale(String lang) {
    switch (lang) {
      case 'FR': return const Locale('fr');
      case 'AR': return const Locale('ar');
      default:   return const Locale('en');
    }
  }

  void changeLocale(Locale locale) async {
    setState(() => _locale = locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode.toUpperCase());
  }

  void changeTheme(bool isDark) async {
    isDarkNotifier.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AgriScan',
          theme: isDark ? AppTheme.theme : AppTheme.lightTheme,
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('ar'),
          ],
          home: SplashScreen(
            onLocaleChange: changeLocale,
            onThemeChange: changeTheme,
            isDarkNotifier: isDarkNotifier,
          ),
        );
      },
    );
  }
}