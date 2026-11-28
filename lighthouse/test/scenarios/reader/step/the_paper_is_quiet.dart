import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the paper is quiet
///
/// Nothing rubbing: the page is not being dragged.
Future<void> thePaperIsQuiet(WidgetTester tester) async {
  expect(app.pageSounds.rubbing, isFalse);
}
