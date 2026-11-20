import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: Then there is no search field
///
/// Only the bar's search button.
Future<void> thereIsNoSearchField(WidgetTester tester) async {
  expect(find.byKey(FloatingTopBar.searchField), findsNothing);
}
