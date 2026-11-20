import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I open the subtitles in the settings panel
Future<void> iOpenTheSubtitlesInTheSettingsPanel(WidgetTester tester) async {
  await tester.tap(find.byKey(PlayerScreen.settingsButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(SettingsMenu.subtitlesRow));
  await tester.pumpAndSettle();
}
