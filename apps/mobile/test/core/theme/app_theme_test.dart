import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';

void main() {
  test('essential parchment text uses high-contrast maroon', () {
    expect(AppTheme.light.colorScheme.onSurface, const Color(0xFF3A1717));
    expect(AppTheme.light.colorScheme.primary, const Color(0xFF8B0E2F));
  });

  test('home reference theme uses parchment surfaces and gold navigation', () {
    expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFFF4D990));
    expect(AppTheme.light.colorScheme.secondary, const Color(0xFFF6D985));
    expect(
      AppTheme.light.navigationBarTheme.backgroundColor,
      const Color(0xFF570005),
    );
  });
}
