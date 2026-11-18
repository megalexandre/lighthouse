import 'package:flutter_test/flutter_test.dart';

import '../../support/player.dart';

/// Usage: When I pause the player
///
/// Paused at 1 s, where the subtitle has a line: the controls hide while
/// playing, and the menus need them up.
Future<void> iPauseThePlayer(WidgetTester tester) async {
  final engine = mpvEngine(tester);
  await engine.pause();
  await engine.seek(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 300));
}
