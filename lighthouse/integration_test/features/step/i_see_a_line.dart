import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// Usage: And I see a line {'2020 · 10s'}
///
/// A text with that in it.
Future<void> iSeeALine(WidgetTester tester, String text) async {
  await waitFor(tester, find.textContaining(text).last);
}
