import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/window_size.dart';

void main() {
  test("Material 3's classes, each starting at its width", () {
    expect(WindowSize.ofWidth(0), WindowSize.compact);
    expect(WindowSize.ofWidth(599.9), WindowSize.compact);
    expect(WindowSize.ofWidth(600), WindowSize.medium);
    expect(WindowSize.ofWidth(839.9), WindowSize.medium);
    expect(WindowSize.ofWidth(840), WindowSize.expanded);
    expect(WindowSize.ofWidth(1199.9), WindowSize.expanded);
    expect(WindowSize.ofWidth(1200), WindowSize.large);
    expect(WindowSize.ofWidth(1600), WindowSize.extraLarge);
  });

  test('atLeast compares the room', () {
    expect(WindowSize.expanded.atLeast(WindowSize.medium), isTrue);
    expect(WindowSize.expanded.atLeast(WindowSize.expanded), isTrue);
    expect(WindowSize.medium.atLeast(WindowSize.expanded), isFalse);
  });
}
