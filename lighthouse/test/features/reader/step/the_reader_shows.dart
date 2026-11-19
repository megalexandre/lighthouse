import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the reader shows {'Page 3 of 5'}
Future<void> theReaderShows(WidgetTester tester, String text) async {
  expect(tester.widget<Text>(find.byKey(ReaderScreen.pageText)).data, text);
}
