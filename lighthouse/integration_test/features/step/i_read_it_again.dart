import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import '../../support/app.dart';

/// Usage: When I read it again
///
/// From the book's page.
Future<void> iReadItAgain(WidgetTester tester) async {
  final read = onScreen(ItemScreen, find.byKey(ItemScreen.readButton));
  await waitFor(tester, read);
  await tapOn(tester, read);
  await waitFor(tester, find.byKey(ReaderScreen.pages));
}
