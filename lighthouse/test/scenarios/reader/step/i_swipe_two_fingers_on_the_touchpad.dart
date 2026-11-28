import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/page_curl/page_curl_painter.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart' show CustomPaint;

import 'world.dart';

/// Usage: When I swipe two fingers {'up'} on the touchpad
///
/// Over the text, 200 px the way said, in small moves, as a touchpad sends
/// them. Notes in [liftedMidSwipe] whether the page curled before the
/// swipe was long enough to turn it (as it would, following the fingers).
Future<void> iSwipeTwoFingersOnTheTouchpad(
  WidgetTester tester,
  String way,
) async {
  final direction = switch (way) {
    'up' => const Offset(0, -1),
    'down' => const Offset(0, 1),
    'left' => const Offset(-1, 0),
    _ => const Offset(1, 0),
  };
  final at =
      tester.getRect(find.byKey(ReaderScreen.pages)).topCenter +
      const Offset(0, 120);
  final pointer = TestPointer(1, PointerDeviceKind.trackpad);
  await tester.sendEventToBinding(pointer.panZoomStart(at));
  liftedMidSwipe = false;
  for (var i = 1; i <= 10; i++) {
    await tester.sendEventToBinding(
      pointer.panZoomUpdate(at, pan: direction * (20.0 * i)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    // Past 60 px the reader turns the page, with its animation: before,
    // nothing should move.
    if (20.0 * i >= 60) continue;
    liftedMidSwipe |= find
        .byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is PageCurlPainter,
        )
        .evaluate()
        .isNotEmpty;
  }
  await tester.sendEventToBinding(pointer.panZoomEnd());
  await tester.pumpAndSettle();
}
