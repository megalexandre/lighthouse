import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: And I open the audio tracks
///
/// In the player's settings panel (the gear).
Future<void> iOpenTheAudioTracks(WidgetTester tester) async {
  await tapOn(tester, find.byKey(PlayerScreen.settingsButton));
  await tapOn(tester, find.byKey(PlayerScreen.audioMenu));
}
