import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: And I pick the {'Portuguese'} audio track from the menu
///
/// Through the settings panel (the gear), its Audio row.
Future<void> iPickTheAudioTrackFromTheMenu(
  WidgetTester tester,
  String language,
) async {
  await tester.tap(find.byKey(PlayerScreen.settingsButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(PlayerScreen.audioMenu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(PlayerScreen.audioItem(audioIndex[language]!)));
  await tester.pumpAndSettle();
}
