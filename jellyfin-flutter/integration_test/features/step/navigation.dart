import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/library_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';
import 'world.dart' as world;

/// Back to home from wherever the scenario is, as a user would: the back
/// button until there is none.
Future<void> backToHome(WidgetTester tester) async {
  final back = find.byType(BackButton).hitTestable();
  while (back.evaluate().isNotEmpty) {
    await tapOn(tester, back.first);
  }
  await waitFor(tester, find.byKey(HomeScreen.viewsRow));
}

/// Home → [library] → the card of [name], which opens its page.
Future<void> openFromLibrary(
  WidgetTester tester,
  String library,
  String name,
) async {
  await backToHome(tester);
  final view = find.descendant(
    of: find.byKey(HomeScreen.viewsRow),
    matching: find.text(library),
  );
  await waitFor(tester, view);
  await tapOn(tester, view);
  final card = onScreen(LibraryScreen, find.text(name));
  await waitFor(tester, card);
  await tapOn(tester, card);
  world.item = name;
}
