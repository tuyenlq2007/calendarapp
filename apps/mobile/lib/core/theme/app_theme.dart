import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFF4D6),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B0E2F),
      primary: const Color(0xFF8B0E2F),
      secondary: const Color(0xFFE0A526),
      surface: const Color(0xFFFFF4D6),
      onSurface: const Color(0xFF3A1717),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(height: 1.35),
    ),
  );
}
