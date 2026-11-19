import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import '../../support/app.dart';

/// Usage: When I close the book
///
/// Back to the book's page.
Future<void> iCloseTheBook(WidgetTester tester) async {
  await tapOn(tester, find.byKey(ReaderScreen.backButton));
  await waitFor(tester, find.byKey(ItemScreen.readButton));
}
