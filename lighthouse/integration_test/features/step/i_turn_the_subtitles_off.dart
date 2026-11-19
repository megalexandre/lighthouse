import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: When I turn the subtitles off
Future<void> iTurnTheSubtitlesOff(WidgetTester tester) async {
  await tapOn(tester, find.byKey(PlayerScreen.subtitleMenu));
  await tapOn(tester, find.byKey(PlayerScreen.subtitleOff));
}
