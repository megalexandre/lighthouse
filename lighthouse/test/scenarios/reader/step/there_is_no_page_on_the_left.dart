import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And there is no page on the left
///
/// One page at a time, or the cover alone on the right.
Future<void> thereIsNoPageOnTheLeft(WidgetTester tester) async {
  expect(find.byKey(ReaderScreen.leftPage), findsNothing);
}
