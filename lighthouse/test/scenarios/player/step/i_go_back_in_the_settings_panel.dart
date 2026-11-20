import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';

/// Usage: And I go back in the settings panel
///
/// Its first row, the arrow back to the list.
Future<void> iGoBackInTheSettingsPanel(WidgetTester tester) async {
  await tester.tap(find.byKey(SettingsMenu.backRow));
  await tester.pumpAndSettle();
}
