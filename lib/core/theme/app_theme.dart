import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

class AppTheme {
  /// 자녀용 — Material 위젯 기본값도 잇다 팔레트에 맞춤
  static ThemeData childTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
      primary: AppColors.orange,
      onPrimary: Colors.white,
      primaryContainer: AppColors.orangeLight,
      onPrimaryContainer: AppColors.orangeDark,
      surface: AppColors.orangePale,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textSub,
      outline: AppColors.border,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.orangePale,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.orangePale,
        foregroundColor: AppColors.text,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: AppColors.orange.withValues(alpha: 0.12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  /// 부모용 — 동일 팔레트 + 큰 글자·터치 영역
  static ThemeData parentTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orangeDark,
      brightness: Brightness.light,
      primary: AppColors.orangeDark,
      onPrimary: Colors.white,
      primaryContainer: AppColors.orangeLight,
      onPrimaryContainer: AppColors.orangeDark,
      surface: AppColors.orangePale,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textSub,
      outline: AppColors.border,
      error: AppColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.orangePale,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.orangePale,
        foregroundColor: AppColors.text,
        toolbarHeight: 64,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.2, color: AppColors.text),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25, color: AppColors.text),
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text),
        titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.text),
        bodyLarge: TextStyle(fontSize: 21, height: 1.35, color: AppColors.text),
        bodyMedium: TextStyle(fontSize: 19, height: 1.35, color: AppColors.textSub),
        labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: AppColors.orange.withValues(alpha: 0.1),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          side: const BorderSide(color: AppColors.orange, width: 2),
          foregroundColor: AppColors.orangeDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

typedef ItdaThemes = AppTheme;
