import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And the position reads {'0:00'}
Future<void> thePositionReads(WidgetTester tester, String text) async {
  expect(tester.widget<Text>(find.byKey(PlayerScreen.positionText)).data, text);
}
