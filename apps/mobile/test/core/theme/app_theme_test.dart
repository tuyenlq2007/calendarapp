import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';

void main() {
  test('essential parchment text uses high-contrast maroon', () {
    expect(AppTheme.light.colorScheme.onSurface, const Color(0xFF3A1717));
    expect(AppTheme.light.colorScheme.primary, const Color(0xFF8B0E2F));
  });
}
