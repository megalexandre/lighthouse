import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_swipes.dart';

void main() {
  test('a swipe seeks a minute for half the width, three for all of it', () {
    expect(swipeSeekOffset(0.5), const Duration(minutes: 1));
    expect(swipeSeekOffset(1), const Duration(minutes: 3));
    expect(swipeSeekOffset(-0.5), const Duration(minutes: -1));
  });

  test('short swipes take finer steps', () {
    expect(swipeSeekOffset(0.1), const Duration(seconds: 7));
    expect(swipeSeekOffset(0.01), const Duration(seconds: 1));
    expect(swipeSeekOffset(0.005), Duration.zero);
  });
}
