import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I read it again
///
/// From the book's page.
Future<void> iReadItAgain(WidgetTester tester) async {
  await tester.tap(find.byKey(ItemScreen.readButton));
  await tester.pumpAndSettle();
  expect(find.byType(ReaderScreen), findsOneWidget);
}
