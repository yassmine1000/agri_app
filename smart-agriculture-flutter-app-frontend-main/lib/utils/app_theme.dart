import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B1120);
  static const Color surface = Color(0xFF0F1B2D);
  static const Color surfaceAlt = Color(0xFF1A2535);
  static const Color border = Color(0xFF1E2D45);
  static const Color borderLight = Color(0xFF1A3045);

  static const Color primary = Color(0xFF00FF88);
  static const Color cyan = Color(0xFF00C4FF);
  static const Color gold = Color(0xFFFFD700);
  static const Color error = Color(0xFFFF4D6A);

  static const Color textPrimary = Color(0xFFE8F4FF);
  static const Color textSecondary = Color(0xFF4A7A9B);
  static const Color textMuted = Color(0xFF2A4A65);
}

class AppColorsLight {
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEEF2F7);
  static const Color border = Color(0xFFDDE3EC);

  static const Color primary = Color(0xFF00B862);
  static const Color cyan = Color(0xFF0099CC);
  static const Color gold = Color(0xFFE6A800);
  static const Color error = Color(0xFFE03050);

  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF5A7A9B);
  static const Color textMuted = Color(0xFF8A9AB0);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surface,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColorsLight.background,
        colorScheme: const ColorScheme.light(
          primary: AppColorsLight.primary,
          surface: AppColorsLight.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsLight.background,
          foregroundColor: AppColorsLight.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColorsLight.textPrimary, letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColorsLight.surface,
          selectedItemColor: AppColorsLight.primary,
          unselectedItemColor: AppColorsLight.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColorsLight.surface,
          labelStyle: const TextStyle(color: AppColorsLight.textSecondary, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColorsLight.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColorsLight.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColorsLight.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColorsLight.surface,
          contentTextStyle: const TextStyle(color: AppColorsLight.textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}