import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import 'world.dart';

/// Usage: And I note where the page is
///
/// For `the page is where it was`.
Future<void> iNoteWhereThePageIs(WidgetTester tester) async {
  pageNoted = tester.getRect(find.byKey(ReaderScreen.pages));
}
