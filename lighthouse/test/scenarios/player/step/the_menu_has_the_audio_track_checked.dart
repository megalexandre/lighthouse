import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart';

/// Usage: And the menu has the {'Portuguese'} audio track checked
///
/// Opens it to look, and closes it again.
Future<void> theMenuHasTheAudioTrackChecked(
  WidgetTester tester,
  String language,
) async {
  await tester.tap(find.byKey(PlayerScreen.settingsButton));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(PlayerScreen.audioMenu));
  await tester.pumpAndSettle();
  expect(
    find.descendant(
      of: find.byKey(PlayerScreen.audioItem(audioIndex[language]!)),
      matching: find.byIcon(Icons.check),
    ),
    findsOneWidget,
  );
  await tester.tapAt(Offset.zero);
  await tester.pumpAndSettle();
}
