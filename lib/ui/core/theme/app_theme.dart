import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppThemes.classic.bg,
      colorScheme: ColorScheme.dark(
        primary: AppThemes.classic.accent,
        surface: AppThemes.classic.surface,
      ),
      fontFamily: 'BebasNeue',
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppThemes.light.bg,
      colorScheme: ColorScheme.light(
        primary: AppThemes.light.accent,
        surface: AppThemes.light.surface,
      ),
      fontFamily: 'BebasNeue',
    );
  }
}
