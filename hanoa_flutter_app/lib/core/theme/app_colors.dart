import 'package:flutter/material.dart';

/// Hanoa 앱의 컬러 팔레트
class AppColors {
  AppColors._();

  // Primary Colors (Hanoa 브랜드 컬러)
  static const Color hanoaNavy = Color(0xFF2C3E50);
  static const Color hanoaGold = Color(0xFFE6BC5A);
  static const Color hanoaLightNavy = Color(0xFF34495E);
  static const Color hanoaDarkNavy = Color(0xFF1A252F);

  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF8F9FA);
  static const Color backgroundLight = Color(0xFFF5F6FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Card & Surface Colors
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color divider = Color(0xFFECF0F1);

  // Button Colors
  static const Color buttonPrimary = hanoaNavy;
  static const Color buttonSecondary = hanoaGold;
  static const Color buttonDisabled = Color(0xFFBDC3C7);

  // Beta Badge Colors
  static const Color betaBadge = hanoaGold;
  static const Color betaText = hanoaNavy;

  // Module Colors (패키지별 개성 색상)
  static const Color moduleStudy = Color(0xFF3498DB);
  static const Color moduleExercise = Color(0xFF2ECC71);
  static const Color moduleRestaurant = Color(0xFFE67E22);
  static const Color moduleChristian = Color(0xFF9B59B6);

  // Shadow Colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hanoaNavy, hanoaLightNavy],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hanoaGold, Color(0xFFF1C40F)],
  );
}