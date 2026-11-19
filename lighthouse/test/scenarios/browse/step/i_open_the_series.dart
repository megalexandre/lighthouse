import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

/// Usage: When I open the series
///
/// The link to it on an episode's page.
Future<void> iOpenTheSeries(WidgetTester tester) async {
  await tester.tap(find.byKey(ItemScreen.seriesLink));
  await tester.pumpAndSettle();
}
