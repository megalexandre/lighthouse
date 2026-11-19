import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: When I tap the search button
///
/// The one in home's top bar.
Future<void> iTapTheSearchButton(WidgetTester tester) async {
  await tester.tap(find.byKey(HomeScreen.searchButton));
  await tester.pumpAndSettle();
}
