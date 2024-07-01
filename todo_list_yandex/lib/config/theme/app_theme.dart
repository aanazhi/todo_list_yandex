import 'package:flutter/material.dart';

@immutable
class AppTheme {
  const AppTheme._();

  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.labelLightPrimary,
    scaffoldBackgroundColor: AppColors.backLightSecondary,
    cardColor: AppColors.backLightElevated,
    dividerColor: AppColors.supportLightSeparator,
    hoverColor: AppColors.supportLightOverlay,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: AppColors.labelLightPrimary,
          fontSize: 32.0,
          fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
        color: AppColors.labelLightSecondary,
        fontSize: 20.0,
      ),
      bodyLarge: TextStyle(
        color: AppColors.labelLightPrimary,
        fontSize: 20.0,
      ),
      bodyMedium: TextStyle(
        color: AppColors.labelLightPrimary,
        fontSize: 16.0,
      ),
      bodySmall: TextStyle(
        color: AppColors.colorLightGray,
        fontSize: 16.0,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.colorLightBlue,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.colorLightBlue,
      secondary: AppColors.colorLightGreen,
      error: AppColors.colorLightRed,
      background: AppColors.backLightPrimary,
      surface: AppColors.backLightSecondary,
      onPrimary: AppColors.colorLightWhite,
      onSecondary: AppColors.colorLightGray,
      onError: AppColors.colorLightWhite,
      onBackground: AppColors.supportLightSeparator,
      onSurface: AppColors.labelLightPrimary,
    ).copyWith(background: AppColors.backLightPrimary),
  );
}

class AppColors {
  // Support [Light]
  static const Color supportLightSeparator = Color(0x33000000);
  static const Color supportLightOverlay = Color(0x0F000000);

  // Label [Light]
  static const Color labelLightPrimary = Color(0xFF000000);
  static const Color labelLightSecondary = Color(0x99000000);
  static const Color labelLightTertiary = Color(0x4D000000);
  static const Color labelLightDisable = Color(0x26000000);

  // Color [Light]
  static const Color colorLightRed = Color(0xFFFF3B30);
  static const Color colorLightGreen = Color(0xFF34C759);
  static const Color colorLightBlue = Color(0xFF007AFF);
  static const Color colorLightGray = Color(0xFF8E8E93);
  static const Color colorLightGrayLight = Color(0xFFD1D1D6);
  static const Color colorLightWhite = Color(0xFFFFFFFF);

  // Back [Light]
  static const Color backLightPrimary = Color(0xFFF7F6F2);
  static const Color backLightSecondary = Color(0xFFFFFFFF);
  static const Color backLightElevated = Color(0xFFFFFFFF);
}
