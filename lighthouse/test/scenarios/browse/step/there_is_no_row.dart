import 'package:flutter_test/flutter_test.dart';

/// Usage: Then there is no {'Next up'} row
///
/// Not even its title.
Future<void> thereIsNoRow(WidgetTester tester, String title) async {
  expect(find.text(title), findsNothing);
}
