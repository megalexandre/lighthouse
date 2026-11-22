import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I swipe back to the previous page
///
/// From the left: on the left page with two side by side (the previous one
/// comes back over the spine), else on the page's left part.
Future<void> iSwipeBackToThePreviousPage(WidgetTester tester) async {
  final left = find.byKey(ReaderScreen.leftPage);
  final area = tester.getRect(
    left.evaluate().isNotEmpty ? left : find.byKey(ReaderScreen.pages),
  );
  await tester.timedDragFrom(
    Offset(area.left + area.width * 0.2, area.center.dy),
    Offset(area.width * 1.2, 0),
    const Duration(milliseconds: 600),
  );
  await tester.pumpAndSettle();
}
