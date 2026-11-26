import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then the panel marks {'episode-1'} as watched
Future<void> thePanelMarksAsWatched(WidgetTester tester, String itemId) async {
  expect(find.byKey(PlayerScreen.panelWatched(itemId)), findsOneWidget);
}
