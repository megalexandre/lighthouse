import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';

/// Usage: And the settings panel is closed
Future<void> theSettingsPanelIsClosed(WidgetTester tester) async {
  expect(find.byType(SettingsMenu), findsNothing);
}
