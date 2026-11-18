import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And I choose the language {'English'}
///
/// In Settings → Appearance; languages are listed in their own names.
Future<void> iChooseTheLanguage(WidgetTester tester, String language) async {
  final field = find.byKey(SettingsScreen.languageField);
  await tester.ensureVisible(field);
  await tester.tap(
    find.descendant(
      of: field,
      matching: find.byWidgetPredicate((w) => w is DropdownButton),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(language).last);
  await tester.pumpAndSettle();
}
