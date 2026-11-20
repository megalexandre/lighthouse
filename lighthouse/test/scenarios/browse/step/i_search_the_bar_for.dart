import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: When I search the bar for {'test'}
///
/// Its button opens a field; Enter searches.
Future<void> iSearchTheBarFor(WidgetTester tester, String text) async {
  await tester.tap(find.byKey(FloatingTopBar.searchButton));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(FloatingTopBar.searchField), text);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();
}
