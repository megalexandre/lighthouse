import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the player is {'dark'}
Future<void> thePlayerIs(WidgetTester tester, String mode) async {
  expect(
    Theme.of(tester.element(find.byKey(PlayerScreen.seekBar))).brightness,
    Brightness.values.byName(mode),
  );
}
