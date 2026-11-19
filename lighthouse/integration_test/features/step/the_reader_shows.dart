import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: Then the reader shows {'Page 3 of 5'}
///
/// An EPUB has its pages once the sheet's size is known, so it waits.
Future<void> theReaderShows(WidgetTester tester, String page) async {
  final label = find.byKey(ReaderScreen.pageText);
  await waitUntil(
    tester,
    () =>
        label.evaluate().isNotEmpty && tester.widget<Text>(label).data == page,
    reason: 'the reader to show "$page"',
  );
}
