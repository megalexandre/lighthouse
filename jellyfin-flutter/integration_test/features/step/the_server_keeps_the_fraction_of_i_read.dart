import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps the fraction of {'Test Novel'} I read
///
/// 12.4 gives an EPUB 10^7 ticks and keeps the fraction read on that
/// scale; its "% read" (what jellyfin-web shows) is that fraction.
Future<void> theServerKeepsTheFractionOfIRead(
  WidgetTester tester,
  String name,
) async {
  final found = await server.findItem(user, name, type: itemType(name));
  expect(found['RunTimeTicks'], 10000000);
  final data = found['UserData'] as Map<String, dynamic>;
  final position = data['PlaybackPositionTicks'] as int;
  expect(position, inExclusiveRange(0, 10000000));
  expect(data['PlayedPercentage'] as num, closeTo(position / 100000, 0.01));
}
