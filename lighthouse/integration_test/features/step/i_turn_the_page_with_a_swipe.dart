import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I turn the page with a swipe
///
/// Lifted from the right half, as one turns a page.
Future<void> iTurnThePageWithASwipe(WidgetTester tester) async {
  final sheet = tester.getRect(find.byKey(ReaderScreen.pages));
  await tester.flingFrom(
    Offset(sheet.left + sheet.width * 0.85, sheet.center.dy),
    Offset(-sheet.width * 0.7, 0),
    1500,
  );
  await tester.pump(const Duration(milliseconds: 500));
}
