import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the reader shows one page at a time
///
/// Stored as chosen in the display settings, so a wide test window does not
/// open two pages (see layout.feature for those).
Future<void> theReaderShowsOnePageAtATime(WidgetTester tester) async {
  storeReaderPreferences({'layout': 'single'});
}
