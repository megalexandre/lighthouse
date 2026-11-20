import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';
import '../../support/player.dart';

/// Usage: Then mpv plays at volume {90}, muted, at {1.5} times the speed
///
/// What the app asked for, as mpv itself reports it.
Future<void> mpvPlaysAtVolumeMutedAtTimesTheSpeed(
  WidgetTester tester,
  num volume,
  num speed,
) async {
  final engine = mpvEngine(tester);
  Future<double> number(String property) async =>
      double.parse(await engine.mpvProperty(property));
  await waitUntil(
    tester,
    () => engine.rate == speed.toDouble(),
    reason: 'the speed reaching mpv',
  );
  expect(await number('volume'), volume);
  expect(await engine.mpvProperty('mute'), 'yes');
  expect(await number('speed'), speed);
}
