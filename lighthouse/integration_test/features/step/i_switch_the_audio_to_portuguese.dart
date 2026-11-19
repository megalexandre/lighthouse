import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: And I switch the audio to Portuguese
///
/// In the settings panel (the gear). Portuguese is the movie's second
/// audio track: stream 3 (tool/gen_fixtures.sh).
Future<void> iSwitchTheAudioToPortuguese(WidgetTester tester) async {
  await tapOn(tester, find.byKey(PlayerScreen.settingsButton));
  await tapOn(tester, find.byKey(PlayerScreen.audioMenu));
  await tapOn(tester, find.byKey(PlayerScreen.audioItem(3)));
}
