import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the text of {'book-epub'} is clear of the phone's bars
///
/// The status and navigation bars, and the notch: the page's own border is
/// wider than them on every side.
Future<void> theTextOfIsClearOfThePhonesBars(
  WidgetTester tester,
  String itemId,
) async {
  final border = epubShown(tester, itemId).margins;
  final bars = tester.view.viewPadding;
  expect(border.left, greaterThan(bars.left));
  expect(border.top, greaterThan(bars.top));
  expect(border.right, greaterThan(bars.right));
  expect(border.bottom, greaterThan(bars.bottom));
}
