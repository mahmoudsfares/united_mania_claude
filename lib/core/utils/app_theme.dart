import 'package:flutter/material.dart';
import 'package:united_mania_claude/core/utils/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.primaryLight,
    onSecondary: AppColors.white,
    surface: AppColors.surface,
    onSurface: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
  );

  static ThemeData get theme {
    final ThemeData base = ThemeData(
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
    );
  }
}
