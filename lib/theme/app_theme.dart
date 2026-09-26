import 'package:flutter/material.dart';

/// Charte graphique reprise du site web Concours-Pro.
class AppColors {
  static const marine = Color(0xFF0F172A);
  static const marineLight = Color(0xFF1E3A8A);
  static const institutionnel = Color(0xFF2563EB);
  static const institutionnelHover = Color(0xFF1D4ED8);
  static const fond = Color(0xFFF8FAFC);
  static const emeraude = Color(0xFF059669);
  static const emeraudeFond = Color(0xFFD1FAE5);
  static const ambre = Color(0xFFD97706);
  static const ambreFond = Color(0xFFFEF3C7);
  static const rouge = Color(0xFFB91C1C);
  static const rougeFond = Color(0xFFFEE2E2);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.fond,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.institutionnel,
        primary: AppColors.institutionnel,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.marine,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.institutionnel,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.institutionnel, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
