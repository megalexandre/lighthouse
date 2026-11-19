import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/ticks.dart';

import '../support/fakes.dart';

void main() {
  test('ticks are 100 ns', () {
    expect(ticksToDuration(10000000), const Duration(seconds: 1));
    expect(durationToTicks(const Duration(minutes: 1)), 600000000);
    // The Test Movie fixture: 10.023 s.
    expect(ticksToDuration(100230000), const Duration(milliseconds: 10023));
  });

  const cases = [
    (Duration(hours: 1, minutes: 32, seconds: 10), '1h 32m'),
    (Duration(hours: 2), '2h'),
    (Duration(minutes: 45), '45m'),
    (Duration(seconds: 10, milliseconds: 230), '10s'),
    (Duration.zero, '0s'),
  ];
  for (final (duration, text) in cases) {
    test('$duration → $text', () => expect(formatRuntime(duration, en), text));
  }
}
