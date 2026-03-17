import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const textTheme = TextTheme(
      displayLarge: AppTextStyles.authScreenTitle,
      headlineLarge: AppTextStyles.authHeroTitle,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodySmall,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonText,
      titleMedium: AppTextStyles.fieldLabel,
    );

    final colorScheme = const ColorScheme.light().copyWith(
      primary: AppColors.accent,
      onPrimary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.black,
      secondary: AppColors.softGrey,
      onSecondary: AppColors.black,
      error: AppColors.error,
      outline: AppColors.black20,
      shadow: AppColors.black10,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      canvasColor: AppColors.white,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTextStyles.fieldLabel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingM,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.authBorderRadius,
          borderSide: const BorderSide(color: AppColors.black20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.authBorderRadius,
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.authBorderRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.authBorderRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(55),
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.black,
          disabledForegroundColor: Colors.white70,
          textStyle: AppTextStyles.buttonText,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.authBorderRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.black80,
          textStyle: AppTextStyles.bodySmall,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.dialogBorderRadius,
        ),
      ),
    );
  }
}
