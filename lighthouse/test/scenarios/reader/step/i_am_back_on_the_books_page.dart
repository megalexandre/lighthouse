import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: Then I am back on the book's page
Future<void> iAmBackOnTheBooksPage(WidgetTester tester) async {
  expect(find.byType(ReaderScreen), findsNothing);
  expect(find.byKey(ItemScreen.readButton), findsOneWidget);
}
