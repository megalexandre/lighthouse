import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: Then I see the page of {'Test Movie (2020)'}
///
/// Its title, on the page on top (others may be underneath).
Future<void> iSeeThePageOf(WidgetTester tester, String name) async {
  await waitUntil(
    tester,
    () =>
        find.byKey(ItemScreen.title).evaluate().isNotEmpty &&
        tester.widgetList<Text>(find.byKey(ItemScreen.title)).last.data == name,
    reason: 'the page of $name',
  );
}
