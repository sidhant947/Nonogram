import 'package:flutter/material.dart';

class GameThemeData {
  const GameThemeData({
    required this.id,
    required this.name,
    required this.bg,
    required this.surface,
    required this.surfaceLight,
    required this.accent,
    required this.buttonBg,
    required this.buttonText,
    required this.gold,
    required this.cellFilled,
    required this.cellCross,
    required this.cellEmpty,
    required this.headingDark,
    required this.subtext,
    required this.border,
    required this.conflictRed,
    this.isDark = true,
  });

  final String id;
  final String name;
  final Color bg;
  final Color surface;
  final Color surfaceLight;
  final Color accent;
  final Color buttonBg;
  final Color buttonText;
  final Color gold;
  final Color cellFilled;
  final Color cellCross;
  final Color cellEmpty;
  final Color headingDark;
  final Color subtext;
  final Color border;
  final Color conflictRed;
  final bool isDark;
}

class AppThemes {
  AppThemes._();

  static const GameThemeData classic = GameThemeData(
    id: 'classic',
    name: 'Classic Dark',
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceLight: Color(0xFF2C2C2C),
    accent: Color(0xFFFFFFFF),
    buttonBg: Color(0xFF000000),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFFFCC00),
    cellFilled: Color(0xFFFFFFFF),
    cellCross: Color(0xFFEF4444),
    cellEmpty: Color(0xFF1E1E1E),
    headingDark: Color(0xFFFFFFFF),
    subtext: Color(0xFFA0A0A0),
    border: Color(0xFF333333),
    conflictRed: Color(0xFFEF4444),
    isDark: true,
  );

  static const GameThemeData matcha = GameThemeData(
    id: 'matcha',
    name: 'Matcha',
    bg: Color(0xFFF1F5E9),
    surface: Color(0xFFE2EAD6),
    surfaceLight: Color(0xFFD3DEC3),
    accent: Color(0xFF588157),
    buttonBg: Color(0xFF3A5A40),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFE9C46A),
    cellFilled: Color(0xFF588157),
    cellCross: Color(0xFFBC4749),
    cellEmpty: Color(0xFFE2EAD6),
    headingDark: Color(0xFF283618),
    subtext: Color(0xFF606C38),
    border: Color(0xFFC7D3B5),
    conflictRed: Color(0xFFBC4749),
    isDark: false,
  );

  static const GameThemeData sakura = GameThemeData(
    id: 'sakura',
    name: 'Sakura',
    bg: Color(0xFFFFF0F3),
    surface: Color(0xFFFFCCD5),
    surfaceLight: Color(0xFFFFB3C1),
    accent: Color(0xFFC9184A),
    buttonBg: Color(0xFF800F2F),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFE09F3E),
    cellFilled: Color(0xFFC9184A),
    cellCross: Color(0xFF590D22),
    cellEmpty: Color(0xFFFFCCD5),
    headingDark: Color(0xFF590D22),
    subtext: Color(0xFFA53860),
    border: Color(0xFFFFB3C1),
    conflictRed: Color(0xFF800F2F),
    isDark: false,
  );

  static const GameThemeData lavender = GameThemeData(
    id: 'lavender',
    name: 'Lavender',
    bg: Color(0xFFF3EDF7),
    surface: Color(0xFFE4D7F0),
    surfaceLight: Color(0xFFD4C2E6),
    accent: Color(0xFF7E57C2),
    buttonBg: Color(0xFF512DA8),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFFFB74D),
    cellFilled: Color(0xFF7E57C2),
    cellCross: Color(0xFFD81B60),
    cellEmpty: Color(0xFFE4D7F0),
    headingDark: Color(0xFF311B92),
    subtext: Color(0xFF673AB7),
    border: Color(0xFFC9B6E0),
    conflictRed: Color(0xFFD81B60),
    isDark: false,
  );

  static const GameThemeData ocean = GameThemeData(
    id: 'ocean',
    name: 'Ocean Breeze',
    bg: Color(0xFFEBF4F6),
    surface: Color(0xFFD1E8ED),
    surfaceLight: Color(0xFFB8DCE3),
    accent: Color(0xFF088395),
    buttonBg: Color(0xFF071952),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFF4A261),
    cellFilled: Color(0xFF088395),
    cellCross: Color(0xFFE63946),
    cellEmpty: Color(0xFFD1E8ED),
    headingDark: Color(0xFF071952),
    subtext: Color(0xFF377D8D),
    border: Color(0xFFA5CDD6),
    conflictRed: Color(0xFFE63946),
    isDark: false,
  );

  static const GameThemeData peach = GameThemeData(
    id: 'peach',
    name: 'Peach Sorbet',
    bg: Color(0xFFFFF3EB),
    surface: Color(0xFFFFE0D0),
    surfaceLight: Color(0xFFFFCCB3),
    accent: Color(0xFFE76F51),
    buttonBg: Color(0xFF9E3A20),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFE9C46A),
    cellFilled: Color(0xFFE76F51),
    cellCross: Color(0xFF6B2D1B),
    cellEmpty: Color(0xFFFFE0D0),
    headingDark: Color(0xFF4A1E11),
    subtext: Color(0xFFA8634A),
    border: Color(0xFFF3BF9F),
    conflictRed: Color(0xFFB02A37),
    isDark: false,
  );

  static const GameThemeData mint = GameThemeData(
    id: 'mint',
    name: 'Mint Froth',
    bg: Color(0xFFEEF9F5),
    surface: Color(0xFFD4EFE4),
    surfaceLight: Color(0xFFBBE5D3),
    accent: Color(0xFF2A9D8F),
    buttonBg: Color(0xFF1E675E),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFF4A261),
    cellFilled: Color(0xFF2A9D8F),
    cellCross: Color(0xFFE76F51),
    cellEmpty: Color(0xFFD4EFE4),
    headingDark: Color(0xFF14453D),
    subtext: Color(0xFF3F8277),
    border: Color(0xFFA6D6C0),
    conflictRed: Color(0xFFD90429),
    isDark: false,
  );

  static const GameThemeData cozyCream = GameThemeData(
    id: 'cozyCream',
    name: 'Cozy Cream',
    bg: Color(0xFFFBF7EE),
    surface: Color(0xFFF0E7D3),
    surfaceLight: Color(0xFFE5D7BC),
    accent: Color(0xFF8C6D46),
    buttonBg: Color(0xFF594324),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFDDA15E),
    cellFilled: Color(0xFF8C6D46),
    cellCross: Color(0xFFA73C2C),
    cellEmpty: Color(0xFFF0E7D3),
    headingDark: Color(0xFF3B2A15),
    subtext: Color(0xFF7D6548),
    border: Color(0xFFD5C4A4),
    conflictRed: Color(0xFFA73C2C),
    isDark: false,
  );

  static const GameThemeData mist = GameThemeData(
    id: 'mist',
    name: 'Morning Mist',
    bg: Color(0xFFEFF2F5),
    surface: Color(0xFFDCE2E8),
    surfaceLight: Color(0xFFCCD5DD),
    accent: Color(0xFF5A738E),
    buttonBg: Color(0xFF2C3E50),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFE5A93B),
    cellFilled: Color(0xFF5A738E),
    cellCross: Color(0xFFC0392B),
    cellEmpty: Color(0xFFDCE2E8),
    headingDark: Color(0xFF1E2B37),
    subtext: Color(0xFF536779),
    border: Color(0xFFBDC7D0),
    conflictRed: Color(0xFFC0392B),
    isDark: false,
  );

  static const GameThemeData sunset = GameThemeData(
    id: 'sunset',
    name: 'Sunset Sky',
    bg: Color(0xFFFDF0ED),
    surface: Color(0xFFF9D6D0),
    surfaceLight: Color(0xFFF3BBB3),
    accent: Color(0xFFD15372),
    buttonBg: Color(0xFF6B243B),
    buttonText: Color(0xFFFFFFFF),
    gold: Color(0xFFF4A261),
    cellFilled: Color(0xFFD15372),
    cellCross: Color(0xFF541388),
    cellEmpty: Color(0xFFF9D6D0),
    headingDark: Color(0xFF451020),
    subtext: Color(0xFF8F4357),
    border: Color(0xFFE4A49C),
    conflictRed: Color(0xFF9E2A2B),
    isDark: false,
  );

  static const List<GameThemeData> allThemes = [
    classic,
    matcha,
    sakura,
    lavender,
    ocean,
    peach,
    mint,
    cozyCream,
    mist,
    sunset,
  ];

  static GameThemeData getThemeById(String? id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => classic,
    );
  }
}

class AppColors {
  AppColors._();

  static GameThemeData _currentTheme = AppThemes.classic;

  static void setTheme(GameThemeData theme) {
    _currentTheme = theme;
  }

  static Color get bg => _currentTheme.bg;
  static Color get surface => _currentTheme.surface;
  static Color get surfaceLight => _currentTheme.surfaceLight;
  static Color get accent => _currentTheme.accent;
  static Color get buttonBg => _currentTheme.buttonBg;
  static Color get buttonText => _currentTheme.buttonText;
  static Color get gold => _currentTheme.gold;
  static Color get cellFilled => _currentTheme.cellFilled;
  static Color get cellCross => _currentTheme.cellCross;
  static Color get cellEmpty => _currentTheme.cellEmpty;
  static Color get headingDark => _currentTheme.headingDark;
  static Color get subtext => _currentTheme.subtext;
  static Color get border => _currentTheme.border;
  static Color get conflictRed => _currentTheme.conflictRed;
}
