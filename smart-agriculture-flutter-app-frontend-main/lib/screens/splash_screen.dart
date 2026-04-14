import 'package:flutter/material.dart';
import '../local/pref_helper.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;
  final ValueNotifier<bool> isDarkNotifier;

  const SplashScreen({
    super.key,
    required this.onLocaleChange,
    required this.onThemeChange,
    required this.isDarkNotifier,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthUser();
  }

  Future<void> _checkAuthUser() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await PrefHelper.getToken();
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(
          onLocaleChange: widget.onLocaleChange,
          onThemeChange: widget.onThemeChange,
          isDarkNotifier: widget.isDarkNotifier,
        )),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(
          onLocaleChange: widget.onLocaleChange,
          onThemeChange: widget.onThemeChange,
          isDarkNotifier: widget.isDarkNotifier,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}