import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';
import '../local/pref_helper.dart';
import 'bottom_screens/detection_screen.dart';
import 'bottom_screens/farmer_screen.dart';
import 'bottom_screens/market_price_screen.dart';
import 'bottom_screens/weather_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PrefHelper.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DetectionScreen(),
      FarmerScreen(),
      MarketPricesScreen(),
      WeatherScreen(),
    ];

    final titles = ['Detection', 'Planning', 'Market', 'Weather'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.cyan]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AGRISCAN',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 2)),
                Text(titles[_currentIndex],
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.biotech_outlined), label: 'Detection'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'Planning'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Market'),
            BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: 'Weather'),
          ],
        ),
      ),
    );
  }
}