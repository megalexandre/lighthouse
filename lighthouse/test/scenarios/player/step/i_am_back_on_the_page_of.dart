import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then I am back on the page of {'Test Movie'}
Future<void> iAmBackOnThePageOf(WidgetTester tester, String name) async {
  expect(find.byType(PlayerScreen), findsNothing);
  expect(tester.widget<Text>(find.byKey(ItemScreen.title)).data, name);
}
