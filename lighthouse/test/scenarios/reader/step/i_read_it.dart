import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I read it
///
/// The Read button of the book's page, already open.
Future<void> iReadIt(WidgetTester tester) async {
  await tester.tap(find.byKey(ItemScreen.readButton));
  await tester.pumpAndSettle();
  expect(find.byType(ReaderScreen), findsOneWidget);
}
