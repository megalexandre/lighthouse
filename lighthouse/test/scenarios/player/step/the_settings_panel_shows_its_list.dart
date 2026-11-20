import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';

/// Usage: Then the settings panel shows its list
///
/// Its first level: Audio, Subtitles, Speed...
Future<void> theSettingsPanelShowsItsList(WidgetTester tester) async {
  expect(find.byKey(SettingsMenu.speedRow), findsOneWidget);
}
