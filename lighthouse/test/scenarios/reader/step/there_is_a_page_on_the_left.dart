import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And there is a page on the left
///
/// Two pages side by side.
Future<void> thereIsAPageOnTheLeft(WidgetTester tester) async {
  expect(find.byKey(ReaderScreen.leftPage), findsOneWidget);
}
