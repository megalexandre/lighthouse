import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I tap the {'right'} edge
///
/// Of the screen, wherever the page sits.
Future<void> iTapTheEdge(WidgetTester tester, String side) async {
  final screen = tester.getRect(find.byType(ReaderScreen));
  await tester.tapAt(
    Offset(
      screen.left + screen.width * (side == 'right' ? 0.95 : 0.05),
      screen.center.dy,
    ),
  );
  await tester.pumpAndSettle();
}
