import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color accentRed = Color(0xFFB22222);
  static const Color textWhite = Colors.white;

  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: accentRed,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textWhite,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        labelLarge: TextStyle(
          color: textWhite,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: textWhite,
          backgroundColor: primaryGold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
    );
  }
}
