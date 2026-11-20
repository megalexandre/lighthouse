import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: When I type {'port'} in the audio language and pick {'Portuguese'}
///
/// The field filters its hundreds of languages as it is typed into.
Future<void> iTypeInTheAudioLanguageAndPick(
  WidgetTester tester,
  String filter,
  String option,
) async {
  final input = find.descendant(
    of: find.byKey(SettingsScreen.audioLanguageField),
    matching: find.byType(TextField),
  );
  await tester.tap(input);
  await tester.pumpAndSettle();
  await tester.enterText(input, filter);
  await tester.pumpAndSettle();
  // Hidden copies of every entry exist too: the menu measures them.
  final shown = find.byType(MenuItemButton).hitTestable().evaluate().length;
  expect(shown, lessThan(5), reason: 'the menu did not filter');
  await tester.tap(find.widgetWithText(MenuItemButton, option).hitTestable());
  await tester.pumpAndSettle();
}
