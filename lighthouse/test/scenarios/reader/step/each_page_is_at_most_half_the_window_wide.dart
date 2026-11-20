import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: Then each page is at most half the window wide
///
/// Two pages side by side: the book is laid out for one of them.
Future<void> eachPageIsAtMostHalfTheWindowWide(WidgetTester tester) async {
  final window = tester.getSize(find.byType(ReaderScreen));
  expect(
    tester.getSize(find.byKey(ReaderScreen.pages)).width,
    lessThanOrEqualTo(window.width / 2),
  );
}
