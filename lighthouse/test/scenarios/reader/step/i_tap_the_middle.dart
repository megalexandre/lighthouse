import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I tap the middle
///
/// Of the screen.
Future<void> iTapTheMiddle(WidgetTester tester) async {
  await tester.tapAt(tester.getRect(find.byType(ReaderScreen)).center);
  await tester.pumpAndSettle();
}
