import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

const _fields = {
  'quality': SettingsScreen.qualityField,
  'subtitles': SettingsScreen.subtitleModeField,
  'theme': SettingsScreen.themeField,
};

/// Usage: When I pick {'Never'} in the {'subtitles'} setting
///
/// Opens its list and picks that.
Future<void> iPickInTheSetting(
  WidgetTester tester,
  String option,
  String setting,
) async {
  final field = find.byKey(_fields[setting]!);
  await tester.ensureVisible(field);
  await tester.tap(
    find.descendant(
      of: field,
      matching: find.byWidgetPredicate((w) => w is DropdownButton),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}
