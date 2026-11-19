import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/ticks.dart';

import 'world.dart' as world;

/// Usage: Then the server keeps the place where I paused
///
/// Within a second of it, and the item's page offers to resume there.
Future<void> theServerKeepsThePlaceWhereIPaused(WidgetTester tester) async {
  final data = await world.userDataOf(world.item);
  final saved = ticksToDuration(data['PlaybackPositionTicks'] as int);
  expect(saved.inSeconds, closeTo(world.pausedAt.inSeconds, 1));
  expect(find.text('Resume from ${formatPosition(saved)}'), findsOneWidget);
  world.savedAt = saved;
}
