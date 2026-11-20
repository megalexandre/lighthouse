import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And the audio language reads {'Portuguese'}
Future<void> theAudioLanguageReads(WidgetTester tester, String name) async {
  final field = tester.widget<TextField>(
    find.descendant(
      of: find.byKey(SettingsScreen.audioLanguageField),
      matching: find.byType(TextField),
    ),
  );
  expect(field.controller!.text, name);
}
