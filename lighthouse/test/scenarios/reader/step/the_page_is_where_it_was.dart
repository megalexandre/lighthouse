import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import 'world.dart';

/// Usage: And the page is where it was
///
/// Same place and size as at `I note where the page is`: an EPUB laid out
/// for another size would be cut into pages again.
Future<void> thePageIsWhereItWas(WidgetTester tester) async {
  expect(tester.getRect(find.byKey(ReaderScreen.pages)), pageNoted);
}
