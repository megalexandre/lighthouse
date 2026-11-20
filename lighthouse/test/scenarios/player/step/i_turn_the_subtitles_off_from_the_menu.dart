import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I turn the subtitles off from the menu
Future<void> iTurnTheSubtitlesOffFromTheMenu(WidgetTester tester) async {
  await tester.tap(find.byKey(PlayerScreen.subtitleMenu));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(PlayerScreen.subtitleOff));
  await tester.pumpAndSettle();
}
