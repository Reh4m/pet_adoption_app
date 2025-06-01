import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/dark_theme.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: LightTheme.primaryColor,
    primaryColorLight: LightTheme.primaryColorLight,
    scaffoldBackgroundColor: LightTheme.backgroundColor,
    colorScheme: ColorScheme.light(
      primary: LightTheme.primaryColor,
      primaryContainer: LightTheme.primaryColorLight,
      onPrimary: LightTheme.onPrimaryColor,
      secondary: LightTheme.secondaryColor,
      secondaryContainer: LightTheme.secondaryColorLight,
      onSecondary: LightTheme.onSecondaryColor,
      surface: LightTheme.cardBackgroundColor,
      onSurface: LightTheme.textPrimary,
      error: LightTheme.error,
      onError: LightTheme.onPrimaryColor,
    ),
    cardColor: LightTheme.cardBackgroundColor,
    textTheme: TextTheme(),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: DarkTheme.primaryColor,
    primaryColorLight: DarkTheme.primaryColorLight,
    scaffoldBackgroundColor: DarkTheme.backgroundColor,
    colorScheme: ColorScheme.dark(
      primary: DarkTheme.primaryColor,
      primaryContainer: DarkTheme.primaryColorLight,
      onPrimary: DarkTheme.onPrimaryColor,
      secondary: DarkTheme.secondaryColor,
      secondaryContainer: DarkTheme.secondaryColorLight,
      onSecondary: DarkTheme.onSecondaryColor,
      surface: DarkTheme.cardBackgroundColor,
      onSurface: DarkTheme.textPrimary,
      error: DarkTheme.error,
      onError: DarkTheme.onPrimaryColor,
    ),
    cardColor: DarkTheme.cardBackgroundColor,
    textTheme: TextTheme(),
  );
}
