import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF610005),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B0E2F),
      primary: const Color(0xFF8B0E2F),
      secondary: const Color(0xFFF6D985),
      surface: const Color(0xFFFFF4D6),
      onSurface: const Color(0xFF3A1717),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF570005),
      indicatorColor: const Color(0xFFFFFDF8),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF9B0F2E), size: 28);
        }
        return const IconThemeData(color: Color(0xFFF6D985), size: 27);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected)
              ? const Color(0xFFFFFDF8)
              : const Color(0xFFF6D985),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: 0,
        );
      }),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(height: 1.35),
    ),
  );
}
