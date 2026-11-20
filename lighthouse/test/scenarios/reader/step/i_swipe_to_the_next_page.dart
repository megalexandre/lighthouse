import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I swipe to the next page
///
/// From the right half, as one turns a page.
Future<void> iSwipeToTheNextPage(WidgetTester tester) async {
  final area = tester.getRect(find.byKey(ReaderScreen.pages));
  await tester.flingFrom(
    Offset(area.left + area.width * 0.8, area.center.dy),
    const Offset(-600, 0),
    1500,
  );
  await tester.pumpAndSettle();
}
