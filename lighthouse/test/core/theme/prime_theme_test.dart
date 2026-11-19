import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';
import 'package:lighthouse/core/theme/theme_builder.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('Prime: every token read, nothing taken from Lanterna', () {
    final lanterna = DesignTokens.parse(
      File('assets/themes/lanterna.json').readAsStringSync(),
    );
    final prime = DesignTokens.parse(
      File('assets/themes/prime.json').readAsStringSync(),
      fallback: lanterna,
    );
    expect(prime.name, 'Prime');
    expect(prime.warnings, isEmpty);
    expect(prime.color('accent', 'dark'), const Color(0xFF1A98FF));
    expect(prime.color('bg-100', 'dark'), const Color(0xFF0F171E));
    expect(prime.color('accent', 'light'), const Color(0xFF0F79D0));
    expect(prime.families['sans']!.first, 'Inter');
    final theme = buildTheme(prime, Brightness.dark);
    expect(theme.textTheme.headlineLarge!.fontSize, 52);
    expect(theme.textTheme.headlineLarge!.fontWeight, FontWeight.w800);
    expect(theme.textTheme.titleLarge!.fontSize, 22); // Shelf titles.
    expect(theme.textTheme.titleLarge!.fontWeight, FontWeight.w700);
    expect(theme.textTheme.bodyMedium!.fontFamily, 'Inter');
  });
}
