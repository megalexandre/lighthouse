import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';

import '../../support/app.dart';
import 'world.dart' as world;

/// Usage: When I open {'Season 1'}
///
/// Its card, on the page shown: an item's page, else the library grid.
Future<void> iOpen(WidgetTester tester, String name) async {
  final onItem = onScreen(ItemScreen, find.text(name));
  final card = onItem.evaluate().isNotEmpty
      ? onItem
      : onScreen(LibraryScreen, find.text(name));
  await waitFor(tester, card);
  await tapOn(tester, card.last);
  world.item = name;
}
