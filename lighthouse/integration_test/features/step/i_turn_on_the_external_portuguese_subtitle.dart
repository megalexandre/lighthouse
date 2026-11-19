import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: When I turn on the external Portuguese subtitle
///
/// The first subtitle listed: the external .por.srt.
Future<void> iTurnOnTheExternalPortugueseSubtitle(WidgetTester tester) async {
  await tapOn(tester, find.byKey(PlayerScreen.subtitleMenu));
  await tapOn(tester, find.byKey(PlayerScreen.subtitleItem(0)));
}
