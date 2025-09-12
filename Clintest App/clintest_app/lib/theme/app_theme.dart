import 'package:flutter/material.dart';

class AppTheme {
  // 밝고 친근한 의료 학습 앱 컬러 팔레트
  static const Color primaryColor = Color(0xFF4CAF50); // Bright Green
  static const Color secondaryColor = Color(0xFF66BB6A); // Light Green  
  static const Color accentColor = Color(0xFF81C784); // Lighter Green
  static const Color errorColor = Color(0xFFE57373); // Light Red
  static const Color warningColor = Color(0xFFFFB74D); // Light Orange
  static const Color successColor = Color(0xFF81C784); // Light Green
  
  static const Color backgroundColor = Color(0xFFFAFAFA); // Very Light Gray
  static const Color backgroundLight = Color(0xFFF5F5F5); // Slightly darker Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White
  static const Color cardColor = Color(0xFFFFFFFF); // Pure White
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        surfaceVariant: backgroundColor,
      ),
      
      // App Bar 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card 테마
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration 테마
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
        // 텍스트 색상 명시적 지정
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textLight),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      
      // TextFormField 전역 텍스트 색상 설정
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary), 
        bodySmall: TextStyle(color: textPrimary),
      ),
      
      // Progress Indicator 테마
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      
      // Tab Bar 테마
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textLight,
        indicatorColor: primaryColor,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: accentColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      
      // 다크 테마의 경우 기본 Material 3 다크 테마 사용
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}

// 커스텀 텍스트 스타일
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppTheme.textLight,
  );
}

// 커스텀 패딩/마진
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}