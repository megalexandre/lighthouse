import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share. Made by `the app as installed` or
/// `the app is signed in`, each scenario its own.
late TestApp app;

/// The built-in themes' files, by the name Settings lists them under.
final _themeFiles = {
  'Lanterna': 'assets/themes/lanterna.json',
  'Prime': 'assets/themes/prime.json',
};

/// Lanterna, the theme every other falls back to.
String get lanterna => File(_themeFiles['Lanterna']!).readAsStringSync();

/// The accent of a built-in theme in that mode ('light' or 'dark').
Color accentOf(String theme, String mode) => DesignTokens.parse(
  File(_themeFiles[theme]!).readAsStringSync(),
  fallback: DesignTokens.parse(lanterna),
).color('accent', mode);

/// '#ff8800' as a colour.
Color hex(String rgb) => Color(int.parse('ff${rgb.substring(1)}', radix: 16));

/// The theme the Settings screen is drawn with.
ThemeData shownTheme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first));
