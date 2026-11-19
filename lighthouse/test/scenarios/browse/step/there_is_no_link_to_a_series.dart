import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

/// Usage: And there is no link to a series
Future<void> thereIsNoLinkToASeries(WidgetTester tester) async {
  expect(find.byKey(ItemScreen.seriesLink), findsNothing);
}
