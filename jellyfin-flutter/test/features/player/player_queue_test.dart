// Playing on: the next episode at the end, Next / Previous, and music
// (album cover, the album playing through).
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  final [e1, e2, e3] = TestItems.episodes;
  const ticksPerSecond = 10000000;

  Future<void> play(WidgetTester tester, String itemId) async {
    await app.open(tester, Routes.item(itemId));
    await tester.tap(find.byKey(ItemScreen.playButton));
    await tester.pumpAndSettle();
  }

  /// Title shown in the player's OSD (an episode: "S1:E2 · Episode 2",
  /// under the series).
  Finder playing(String name) => find.descendant(
    of: find.byType(PlayerScreen),
    matching: find.textContaining(name),
  );

  Future<void> leave(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }

  testWidgets('an episode played to the end: the next one starts', (
    tester,
  ) async {
    await play(tester, e1.id);
    app.engine.finish();
    await tester.pumpAndSettle();

    expect(playing(e2.name), findsOneWidget);
    expect(app.engines, hasLength(2));
    expect(app.engines.first.disposed, isTrue);
    expect(app.engine.openedUrl!.path, '/Videos/${e2.id}/stream');
    expect(app.engine.openedStart, Duration.zero);
    // Episode 1 was reported finished, at its length.
    final stop = app.playback.stopped.single;
    expect(stop.itemId, e1.id);
    expect(stop.positionTicks, 600 * ticksPerSecond);
    expect(app.playback.started.map((s) => s.itemId), [e1.id, e2.id]);

    // Back goes to the page playback started from.
    await leave(tester);
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(find.text(e1.name), findsWidgets);
  });

  testWidgets('the last episode played to the end: back to the details', (
    tester,
  ) async {
    await play(tester, e3.id);
    expect(find.byKey(PlayerScreen.nextButton), findsNothing);
    app.engine.finish();
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsNothing);
    expect(find.byType(ItemScreen), findsOneWidget);
  });

  testWidgets('Next: saves where this one was, plays the next', (tester) async {
    await play(tester, e1.id);
    app.engine.advance(const Duration(seconds: 20));
    await tester.tap(find.byKey(PlayerScreen.nextButton));
    await tester.pumpAndSettle();

    expect(playing(e2.name), findsOneWidget);
    expect(app.playback.stopped.single.positionTicks, 20 * ticksPerSecond);
    await leave(tester);
  });

  testWidgets('Previous: restarts after 3 s, else the previous episode', (
    tester,
  ) async {
    await play(tester, e2.id);
    app.engine.advance(const Duration(seconds: 10));
    await tester.tap(find.byKey(PlayerScreen.previousButton));
    await tester.pumpAndSettle();
    expect(playing(e2.name), findsOneWidget);
    expect(app.engine.position, Duration.zero);

    await tester.tap(find.byKey(PlayerScreen.previousButton));
    await tester.pumpAndSettle();
    expect(playing(e1.name), findsOneWidget);

    // The first one has nothing before: Previous only restarts.
    app.engine.advance(const Duration(seconds: 1));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(playing(e1.name), findsOneWidget);
    expect(app.engine.position, Duration.zero);
    await leave(tester);
  });

  testWidgets('media keys: next track', (tester) async {
    await play(tester, e1.id);
    await tester.sendKeyEvent(LogicalKeyboardKey.mediaTrackNext);
    await tester.pumpAndSettle();
    expect(playing(e2.name), findsOneWidget);
    await leave(tester);
  });

  testWidgets('a movie has no Next', (tester) async {
    await play(tester, TestItems.testMovie.id);
    expect(find.byKey(PlayerScreen.nextButton), findsNothing);
    await leave(tester);
  });

  testWidgets('an album: the cover, the OSD stays, and it plays through', (
    tester,
  ) async {
    final [t1, t2] = TestItems.tracks;
    await play(tester, TestItems.testAlbum.id);

    expect(find.byKey(PlayerScreen.cover), findsOneWidget);
    expect(playing(t1.name), findsWidgets);
    expect(find.text('Test Artist · Test Album'), findsOneWidget);
    expect(app.engine.openedUrl, FakePlaybackRepository.urlFor(t1.id));

    // No picture to look at: the controls do not hide.
    await tester.pump(const Duration(seconds: 5));
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );

    app.engine.finish();
    await tester.pumpAndSettle();
    expect(playing(t2.name), findsWidgets);

    app.engine.finish();
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsNothing);
  });

  testWidgets('a track of the album, picked from the list', (tester) async {
    final t2 = TestItems.tracks[1];
    await app.open(tester, Routes.item(TestItems.testAlbum.id));
    await tester.tap(find.byKey(ItemScreen.trackKey(t2.id)));
    await tester.pumpAndSettle();
    expect(playing(t2.name), findsWidgets);
    expect(find.byKey(PlayerScreen.nextButton), findsNothing);
    await leave(tester);
  });

  testWidgets('binge: full screen, volume and mute carry to the next '
      'episode; leaving the player gives the window back', (tester) async {
    await play(tester, e1.id);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    expect(app.window.isFullScreen, isTrue);
    expect((app.engine.volume, app.engine.muted), (90.0, true));

    app.engine.finish();
    await tester.pumpAndSettle();
    expect(playing(e2.name), findsOneWidget);
    expect(app.window.isFullScreen, isTrue);
    expect((app.engine.volume, app.engine.muted), (90.0, true));

    // Next, by its key: the same.
    await tester.sendKeyEvent(LogicalKeyboardKey.mediaTrackNext);
    await tester.pumpAndSettle();
    expect(app.window.isFullScreen, isTrue);

    await leave(tester);
    expect(find.byType(PlayerScreen), findsNothing);
    expect(app.window.isFullScreen, isFalse);
  });
}
