import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the server keeps a fraction of {'book-epub'}
///
/// 12.4 keeps an EPUB's place as the fraction read, of its 10^7 ticks:
/// somewhere past the start, before the end.
Future<void> theServerKeepsAFractionOf(
  WidgetTester tester,
  String itemId,
) async {
  final (id, position) = app.books.saved.single;
  expect(id, itemId);
  final book = app.library.books.firstWhere((b) => b.id == itemId);
  expect(position, inExclusiveRange(0, book.runTimeTicks!));
}
