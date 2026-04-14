import 'package:flutter/material.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../local/pref_helper.dart';
import 'bottom_screens/detection_screen.dart';
import 'bottom_screens/farmer_screen.dart';
import 'bottom_screens/market_price_screen.dart';
import 'bottom_screens/weather_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Function(bool) onThemeChange;
  final ValueNotifier<bool> isDarkNotifier;

  const MainScreen({
    super.key,
    required this.onLocaleChange,
    required this.onThemeChange,
    required this.isDarkNotifier,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Future<void> _logout(bool isDark) async {
    final l = AppLocalizations.of(context)!;
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        title: Text(l.signOut, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text(l.signOutConfirm, style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel, style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.signOut, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PrefHelper.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(
          onLocaleChange: widget.onLocaleChange,
          onThemeChange: widget.onThemeChange,
          isDarkNotifier: widget.isDarkNotifier,
        )),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final l = AppLocalizations.of(context)!;
        final bg = isDark ? AppColors.background : AppColorsLight.background;
        final surface = isDark ? AppColors.surface : AppColorsLight.surface;
        final border = isDark ? AppColors.border : AppColorsLight.border;
        final primary = isDark ? AppColors.primary : AppColorsLight.primary;
        final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
        final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;

        final screens = [
          DetectionScreen(isDarkMode: isDark),
          FarmerScreen(isDarkMode: isDark),
          MarketPricesScreen(isDarkMode: isDark),
          WeatherScreen(isDarkMode: isDark),
        ];
        final titles = [l.detection, l.planning, l.market, l.weather];

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            title: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, cyan]),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(child: Text('🌿', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('AGRISCAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: 2)),
                Text(titles[_currentIndex], style: TextStyle(fontSize: 11, color: textSecondary)),
              ]),
            ]),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: textSecondary, size: 20),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen(
                    onLocaleChange: widget.onLocaleChange,
                    onThemeChange: widget.onThemeChange,
                    isDarkNotifier: widget.isDarkNotifier,
                  )),
                ),
              ),
              IconButton(
                icon: Icon(Icons.logout_rounded, color: textSecondary, size: 20),
                onPressed: () => _logout(isDark),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: border),
            ),
          ),
          body: screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: surface,
              border: Border(top: BorderSide(color: border)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: primary,
              unselectedItemColor: textSecondary,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.biotech_outlined), label: l.detection),
                BottomNavigationBarItem(icon: const Icon(Icons.event_note_outlined), label: l.planning),
                BottomNavigationBarItem(icon: const Icon(Icons.storefront_outlined), label: l.market),
                BottomNavigationBarItem(icon: const Icon(Icons.wb_sunny_outlined), label: l.weather),
              ],
            ),
          ),
        );
      },
    );
  }
}