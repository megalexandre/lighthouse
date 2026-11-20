import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:lighthouse/router.dart';

import 'world.dart';

/// Usage: When I read {'book-comic'}
///
/// From the book's page, its Read button.
Future<void> iRead(WidgetTester tester, String itemId) async {
  await app.open(tester, Routes.item(itemId), window: window);
  await tester.tap(find.byKey(ItemScreen.readButton));
  await tester.pumpAndSettle();
  expect(find.byType(ReaderScreen), findsOneWidget);
}
