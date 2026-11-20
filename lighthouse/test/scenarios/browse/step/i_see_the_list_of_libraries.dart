import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/features/library/presentation/libraries_screen.dart';

import '../../../support/fakes.dart';

/// Usage: Then I see the list of libraries
///
/// The Libraries page, a card for each.
Future<void> iSeeTheListOfLibraries(WidgetTester tester) async {
  expect(find.byType(LibrariesScreen), findsOneWidget);
  for (final view in TestItems.views) {
    expect(find.byKey(ItemCard.keyFor(view.id)), findsOneWidget);
  }
}
