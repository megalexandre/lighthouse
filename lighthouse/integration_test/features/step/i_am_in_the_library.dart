import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';

import '../../support/app.dart';

/// Usage: Then I am in the library
///
/// Its grid, with no page over it.
Future<void> iAmInTheLibrary(WidgetTester tester) async {
  await waitFor(tester, find.byType(LibraryScreen));
  await waitUntil(
    tester,
    () => find.byType(ItemScreen).evaluate().isEmpty,
    reason: 'the page closed',
  );
}
