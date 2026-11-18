import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';

/// Usage: Then I see the setting {'Idioma'}
///
/// A setting's name on the Settings screen, in the app's language.
Future<void> iSeeTheSetting(WidgetTester tester, String name) async {
  expect(
    find.descendant(of: find.byType(SettingsScreen), matching: find.text(name)),
    findsOneWidget,
  );
}
