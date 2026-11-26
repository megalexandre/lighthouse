import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart';

/// Usage: Then the panel lists {'1. Episode 1, 2. Episode 2'}
///
/// Those rows, in that order, and no others.
Future<void> thePanelLists(WidgetTester tester, String titles) async {
  final wanted = titles.split(', ');
  final tops = [
    for (final title in wanted) tester.getTopLeft(panelRow(title)).dy,
  ];
  expect(tops, orderedEquals([...tops]..sort()));
  final rows = find.descendant(
    of: find.byKey(PlayerScreen.sidePanel),
    matching: find.byType(InkWell),
  );
  // The rows, besides the close button and the season chips.
  final shown = rows.evaluate().where(
    (e) => wanted.any(
      (t) => find
          .descendant(of: find.byWidget(e.widget), matching: find.text(t))
          .evaluate()
          .isNotEmpty,
    ),
  );
  expect(shown, hasLength(wanted.length));
}
