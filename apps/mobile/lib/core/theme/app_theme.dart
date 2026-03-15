import 'package:flutter/material.dart';

import '../design/app_design.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
            seedColor: AppColors.brand, brightness: Brightness.light)
        .copyWith(
      surface: AppColors.background,
      primary: AppColors.brand,
      secondary: AppColors.textSecondary,
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.border),
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F4F8),
        selectedColor: const Color(0xFFEAF0FF),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1),
        headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.15),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2),
        titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2),
        titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3),
        bodyLarge: TextStyle(
            fontSize: 13, height: 1.45, color: AppColors.textSecondary),
        bodyMedium: TextStyle(
            fontSize: 12, height: 1.45, color: AppColors.textSecondary),
        bodySmall: TextStyle(
            fontSize: 11, height: 1.35, color: AppColors.textSecondary),
      ),
    );
  }
}
