import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(surface: Colors.white, onSurface: AppColors.ink),
        scaffoldBackgroundColor: AppColors.scaffold,
        textTheme: const TextTheme(
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyMedium: AppTextStyles.bodyMedium,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkInk,
          onSurfaceVariant: AppColors.darkMuted,
          outlineVariant: AppColors.darkSurfaceBorder,
        ),
        scaffoldBackgroundColor: AppColors.darkScaffold,
        textTheme: const TextTheme(
          titleLarge: AppTextStyles.darkTitleLarge,
          titleMedium: AppTextStyles.darkTitleMedium,
          bodyMedium: AppTextStyles.darkBodyMedium,
        ),
      );
}
