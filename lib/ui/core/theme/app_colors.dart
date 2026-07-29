import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF121212); // Charcoal Black (Dark interface background)
  static const Color surface = Color(0xFF1E1E1E); // Dark surface container
  static const Color surfaceLight = Color(0xFF2C2C2C);
  
  static const Color accent = Color(0xFFFFFFFF); // Pure White primary accent
  static const Color buttonBg = Color(0xFF000000); // Pure Black (Button fill background)
  static const Color buttonText = Color(0xFFFFFFFF); // Pure White (Button text font)
  static const Color gold = Color(0xFFFFCC00); // Gold for hints/stars

  static const Color cellFilled = Color(0xFFFFFFFF); // Filled nonogram cell color
  static const Color cellCross = Color(0xFFEF4444); // Cross / X mark color
  static const Color cellEmpty = Color(0xFF1E1E1E);

  static const Color headingDark = Color(0xFFFFFFFF); // Pure White heading text
  static const Color subtext = Color(0xFFA0A0A0);
  static const Color border = Color(0xFF333333);
  static const Color conflictRed = Color(0xFFEF4444);
}
