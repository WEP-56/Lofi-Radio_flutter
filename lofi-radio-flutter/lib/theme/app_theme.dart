import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentDim,
          surface: AppColors.surface,
          onPrimary: AppColors.backgroundDeep,
          onSurface: AppColors.textPrimary,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
          inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
          thumbColor: AppColors.accent,
          overlayColor: AppColors.accent.withValues(alpha: 0.12),
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        ),
        iconTheme: IconThemeData(
          color: AppColors.textSecondary,
          size: 22,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      );
}
