import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: When I open the search field
///
/// The top bar's search button, where the bar has room for the field.
Future<void> iOpenTheSearchField(WidgetTester tester) async {
  await tester.tap(find.byKey(FloatingTopBar.searchButton));
  await tester.pumpAndSettle();
  expect(find.byKey(FloatingTopBar.searchField), findsOneWidget);
}
