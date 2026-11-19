import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';

/// Usage: When I search for {'test'}
///
/// Types it, and waits the pause after which the app asks the server.
Future<void> iSearchFor(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(SearchScreen.field), text);
  await tester.pump(SearchScreen.debounce);
  await tester.pumpAndSettle();
}
