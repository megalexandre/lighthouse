import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And there are no type settings
///
/// A PDF or a comic is pictures: its type cannot change.
Future<void> thereAreNoTypeSettings(WidgetTester tester) async {
  expect(find.byKey(ReaderScreen.fontBigger), findsNothing);
}
