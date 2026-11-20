import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

/// Usage: When I mark it read
///
/// From the book's page.
Future<void> iMarkItRead(WidgetTester tester) async {
  await tester.tap(find.byKey(ItemScreen.watchedButton));
  await tester.pumpAndSettle();
}
