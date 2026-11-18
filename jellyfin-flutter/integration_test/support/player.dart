import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/application/player_controller.dart';
import 'package:jellyfin_flutter/features/player/data/player_engine.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

/// What the player's position label shows, as a duration.
Duration shownPosition(WidgetTester tester) {
  final text = tester.widget<Text>(find.byKey(PlayerScreen.positionText));
  final [m, s] = text.data!.split(':').map(int.parse).toList();
  return Duration(minutes: m, seconds: s);
}

/// The mpv engine behind the player on screen, to read its properties.
MediaKitEngine mpvEngine(WidgetTester tester) {
  final request = tester
      .widget<PlayerScreen>(find.byType(PlayerScreen))
      .request;
  final container = ProviderScope.containerOf(
    tester.element(find.byType(PlayerScreen)),
  );
  return container.read(playerControllerProvider(request)).value!.engine
      as MediaKitEngine;
}

/// Waits until mpv's [property] is [expected].
Future<void> mpvShows(
  WidgetTester tester,
  String property,
  String expected,
) async {
  final engine = mpvEngine(tester);
  var last = '';
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    last = await engine.mpvProperty(property);
    if (last == expected) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('mpv $property is "$last", expected "$expected"');
}
