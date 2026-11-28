import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/page_curl/curl_geometry.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  const size = Size(300, 420);

  test('a straight drag from the middle of the edge folds along a vertical '
      'line', () {
    final curl = curlFor(size, const Offset(300, 210), const Offset(100, 210))!;
    expect(curl.direction.dx, closeTo(1, 1e-9));
    expect(curl.direction.dy, closeTo(0, 1e-9));
    // The grabbed edge lies flat on top, right under the finger.
    final s = 300 - curl.point.dx;
    expect(curl.point.dx - (s - math.pi * curl.radius), closeTo(100, 1e-6));
  });

  test('a corner pulled up and in folds diagonally (the corner first)', () {
    final curl = curlFor(size, const Offset(300, 400), const Offset(200, 300))!;
    expect(curl.direction.dx, greaterThan(0));
    expect(curl.direction.dy, greaterThan(0));
    expect(curl.direction.distance, closeTo(1, 1e-9));
  });

  test('the radius grows with the drag, up to the maximum', () {
    double radius(double dx) =>
        curlFor(size, const Offset(300, 210), Offset(300 - dx, 210))!.radius;
    expect(radius(10), closeTo(10 / math.pi, 1e-9));
    expect(radius(200), maxCurlRadius(size));
    expect(
      curlFor(size, const Offset(300, 210), const Offset(300, 210)),
      isNull,
    );
  });

  test('the sheet stays bound at the spine', () {
    const grab = Offset(300, 210);
    final far = constrainToSpine(size, grab, const Offset(-900, 210));
    expect(far.dx, closeTo(-300, 1e-6), reason: 'no further than turned');
    final f = constrainToSpine(size, grab, const Offset(100, 900));
    expect(
      (f - Offset(0, size.height)).distance,
      lessThanOrEqualTo((grab - Offset(0, size.height)).distance + 1e-9),
    );
  });

  test('the sheet never moves more than the finger, anywhere', () {
    // A page of a spread; grabbed high, in the middle and low on the edge.
    const size = Size(438, 608);
    for (final gy in [0.1, 0.5, 0.88]) {
      final grab = Offset(size.width, size.height * gy);
      for (var x = -size.width - 100; x <= size.width + 50; x += 4) {
        for (var y = -300.0; y <= size.height + 300; y += 4) {
          final p = Offset(x, y);
          for (final d in const [Offset(1, 0), Offset(0, 1)]) {
            final moved =
                (constrainToSpine(size, grab, p + d) -
                        constrainToSpine(size, grab, p))
                    .distance;
            expect(
              moved,
              lessThanOrEqualTo(1.001),
              reason: 'grabbed at $grab, finger at $p',
            );
          }
        }
      }
    }
  });

  test('fully turned: the grabbed point mirrored over the spine', () {
    expect(turnedFinger(const Offset(300, 200)), const Offset(-300, 200));
  });

  test('let go: a flick decides, else the middle', () {
    expect(
      shouldTurn(size, const Offset(250, 0), const Offset(-800, 0)),
      isTrue,
    );
    expect(
      shouldTurn(size, const Offset(50, 0), const Offset(800, 0)),
      isFalse,
    );
    expect(shouldTurn(size, const Offset(140, 0), Offset.zero), isTrue);
    expect(shouldTurn(size, const Offset(160, 0), Offset.zero), isFalse);
  });

  test('what is left settles faster than a full turn', () {
    final full = settleDuration(
      size,
      const Offset(300, 0),
      const Offset(-300, 0),
    );
    final little = settleDuration(
      size,
      const Offset(-250, 0),
      const Offset(-300, 0),
    );
    expect(full, const Duration(milliseconds: 350));
    expect(little, lessThan(full));
  });
}
