import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I scroll the touchpad {'down'} in a burst
///
/// Many small scrolls a few milliseconds apart, as one swipe of two
/// fingers sends.
Future<void> iScrollTheTouchpadInABurst(WidgetTester tester, String way) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  final at = tester.getCenter(find.byKey(ReaderScreen.pages));
  await tester.sendEventToBinding(pointer.hover(at));
  for (var i = 0; i < 20; i++) {
    await tester.sendEventToBinding(
      pointer.scroll(Offset(0, way == 'down' ? 12 : -12)),
    );
    await tester.pump(const Duration(milliseconds: 8));
  }
  await tester.pumpAndSettle();
}
