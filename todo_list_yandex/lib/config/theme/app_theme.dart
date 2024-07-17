import 'package:flutter/material.dart';

@immutable
class AppTheme {
  const AppTheme._();
  static final light = ThemeData(
    useMaterial3: false,
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
      onPrimary: AppColors.backLightPrimary,
      surface: AppColors.backLightSecondary,
      onSecondary: AppColors.colorLightGray,
      onError: AppColors.supportLightSeparator,
      onSurface: AppColors.labelLightPrimary,
    ).copyWith(onPrimary: AppColors.backLightPrimary),
  );

  static final dark = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: AppColors.labelDarkPrimary,
    scaffoldBackgroundColor: AppColors.backDarkSecondary,
    cardColor: AppColors.backDarkElevated,
    dividerColor: AppColors.supportDarkSeparator,
    hoverColor: AppColors.supportDarkOverlay,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: AppColors.labelDarkPrimary,
          fontSize: 32.0,
          fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
        color: AppColors.labelDarkSecondary,
        fontSize: 20.0,
      ),
      bodyLarge: TextStyle(
        color: AppColors.labelDarkPrimary,
        fontSize: 20.0,
      ),
      bodyMedium: TextStyle(
        color: AppColors.labelDarkPrimary,
        fontSize: 16.0,
      ),
      bodySmall: TextStyle(
        color: AppColors.colorDarkGray,
        fontSize: 16.0,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.colorDarkBlue,
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.colorDarkBlue,
      secondary: AppColors.colorDarkGreen,
      error: AppColors.colorDarkRed,
      onPrimary: AppColors.backDarkPrimary,
      surface: AppColors.backDarkSecondary,
      onSecondary: AppColors.colorDarkGray,
      onError: AppColors.supportDarkSeparator,
      onSurface: AppColors.labelDarkPrimary,
    ).copyWith(onPrimary: AppColors.backDarkPrimary),
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

  // Support [Dark]
  static const Color supportDarkSeparator = Color(0x33FFFFFF);
  static const Color supportDarkOverlay = Color(0x52000000);

  // Label [Dark]
  static const Color labelDarkPrimary = Color(0xFFFFFFFF);
  static const Color labelDarkSecondary = Color(0x99FFFFFF);
  static const Color labelDarkTertiary = Color(0x66FFFFFF);
  static const Color labelDarkDisable = Color(0x26FFFFFF);

  // Color [Dark]
  static const Color colorDarkRed = Color(0xFFFF453A);
  static const Color colorDarkGreen = Color(0xFF32D74B);
  static const Color colorDarkBlue = Color(0xFF0A84FF);
  static const Color colorDarkGray = Color(0xFF8E8E93);
  static const Color colorDarkGrayLight = Color(0xFF48484A);
  static const Color colorDarkWhite = Color(0xFFFFFFFF);

  // Back [Dark]
  static const Color backDarkPrimary = Color(0xFF161618);
  static const Color backDarkSecondary = Color(0xFF252528);
  static const Color backDarkElevated = Color(0xFF3C3C3F);
}
