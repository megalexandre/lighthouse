import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';

/// Usage: And I open {'Test Movie'}
///
/// Its card among the results.
Future<void> iOpen(WidgetTester tester, String name) async {
  await tester.tap(
    find.descendant(of: find.byType(SearchScreen), matching: find.text(name)),
  );
  await tester.pumpAndSettle();
}
