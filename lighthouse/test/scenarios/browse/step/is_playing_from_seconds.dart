import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: Then {'Episode 2'} is playing from {0} seconds
///
/// The stream the player opened is that item's, from there.
Future<void> isPlayingFromSeconds(
  WidgetTester tester,
  String name,
  num seconds,
) async {
  expect(find.byType(PlayerScreen), findsOneWidget);
  expect(app.engine.openedUrl?.pathSegments, contains(itemNamed(name).id));
  expect(app.engine.openedStart, Duration(seconds: seconds.toInt()));
}
