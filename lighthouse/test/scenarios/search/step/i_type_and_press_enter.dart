import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';

/// Usage: When I type {'movie'} and press Enter
///
/// No time passes after: not the pause after which typing searches.
Future<void> iTypeAndPressEnter(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(SearchScreen.field), text);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pump();
  await tester.pump();
}
