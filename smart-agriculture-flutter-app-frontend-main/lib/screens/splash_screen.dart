import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import '../local/pref_helper.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _checkAuthUser();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuthUser() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final token = await PrefHelper.getToken();
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => MainScreen(
            onLocaleChange: widget.onLocaleChange,
            onThemeChange:  widget.onThemeChange,
            isDarkNotifier: widget.isDarkNotifier,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => OnboardingScreen(
            onLocaleChange: widget.onLocaleChange,
            onThemeChange:  widget.onThemeChange,
            isDarkNotifier: widget.isDarkNotifier,
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final bg            = isDark ? AppColors.background    : AppColorsLight.background;
        final primary       = isDark ? AppColors.primary       : AppColorsLight.primary;
        final cyan          = isDark ? AppColors.cyan          : AppColorsLight.cyan;
        final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

        return Scaffold(
          backgroundColor: bg,
          body: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset('assets/icons/agriscan_logo.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AgriScan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.appTagline,
                      style: TextStyle(fontSize: 12, color: textSecondary, letterSpacing: 1),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                        color: primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}