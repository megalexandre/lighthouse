import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I close the book
///
/// Back to the book's page.
Future<void> iCloseTheBook(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.backButton));
  await tester.pumpAndSettle();
  expect(find.byKey(ItemScreen.readButton), findsOneWidget);
}
