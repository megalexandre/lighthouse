import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I scroll the mouse wheel {'down'}
///
/// One notch over the page, then a pause, as a hand on a wheel.
Future<void> iScrollTheMouseWheel(WidgetTester tester, String way) async {
  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  final at = tester.getCenter(find.byKey(ReaderScreen.pages));
  await tester.sendEventToBinding(pointer.hover(at));
  await tester.sendEventToBinding(
    pointer.scroll(Offset(0, way == 'down' ? 53 : -53)),
  );
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 300));
}
