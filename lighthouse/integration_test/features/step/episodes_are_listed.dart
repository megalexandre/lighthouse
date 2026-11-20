import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

import '../../support/app.dart';

/// Usage: And {3} episodes are listed
///
/// "1. Test Show S01E01"... on the season's page.
Future<void> episodesAreListed(WidgetTester tester, num count) async {
  await waitFor(
    tester,
    onScreen(ItemScreen, find.text('$count. ${Fixtures.testShow} S01E0$count')),
  );
  expect(
    onScreen(ItemScreen, find.textContaining('. ${Fixtures.testShow} S01E0')),
    findsNWidgets(count.toInt()),
  );
}
