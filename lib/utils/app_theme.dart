import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFF5F4F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF0EFE9);
  static const Color border = Color(0xFFDDDBD3);
  static const Color border2 = Color(0xFFC8C6BC);

  static const Color text = Color(0xFF1A1917);
  static const Color text2 = Color(0xFF6B6860);
  static const Color text3 = Color(0xFF9E9C96);

  static const Color green = Color(0xFF2D6A4F);
  static const Color greenBg = Color(0xFFE8F5EE);

  static const Color red = Color(0xFF9B2335);
  static const Color redBg = Color(0xFFFDF0F0);

  static const Color blue = Color(0xFF1A4A8A);
  static const Color blueBg = Color(0xFFEEF3FB);

  static const Color amber = Color(0xFF7A4A00);
  static const Color amberBg = Color(0xFFFDF5E6);

  static const Color purple = Color(0xFF5B3A8A);
  static const Color purpleBg = Color(0xFFF3EEFB);

  static BorderRadius radius = BorderRadius.circular(8);
  static BorderRadius radiusLarge = BorderRadius.circular(12);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: text,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: text),
      ),
    ),
  );
}