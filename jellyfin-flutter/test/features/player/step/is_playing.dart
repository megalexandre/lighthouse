import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: Then {'episode-2'} is playing
///
/// The player is up, and the stream it opened last is that item's.
Future<void> isPlaying(WidgetTester tester, String itemId) async {
  expect(find.byType(PlayerScreen), findsOneWidget);
  expect(app.engine.openedUrl?.pathSegments, contains(itemId));
}
