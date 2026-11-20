import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: And I pick the {'Portuguese'} subtitle from the menu
///
/// The subtitles button of the bar.
Future<void> iPickTheSubtitleFromTheMenu(
  WidgetTester tester,
  String language,
) async {
  await tester.tap(find.byKey(PlayerScreen.subtitleMenu));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(PlayerScreen.subtitleItem(subtitleIndex[language]!)),
  );
  await tester.pumpAndSettle();
}
