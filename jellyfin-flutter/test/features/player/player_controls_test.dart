// The F3b controls of the player screen, with the fake engine: track
// menus, the keys from keyboard.json, volume, full screen.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/playback_report.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  Future<void> startPlaying(WidgetTester tester) async {
    await app.open(tester, Routes.item(TestItems.testMovie.id));
    await tester.tap(find.byKey(ItemScreen.playButton));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsOneWidget);
  }

  /// Leaves the player (flushing the OSD timer) at the end of a test.
  Future<void> leave(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, Key menu, Key item) async {
    await tester.tap(find.byKey(menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(item));
    await tester.pumpAndSettle();
  }

  PlaybackProgressInfo lastReport() => app.playback.progress.last;

  testWidgets('starts with the server default audio, no subtitle', (
    tester,
  ) async {
    await startPlaying(tester);
    expect(app.engine.trackLog, ['audio 1', 'subtitle no']);
    expect(app.playback.started.single.audioStreamIndex, 2);
    expect(app.playback.started.single.subtitleStreamIndex, -1);
    await leave(tester);
  });

  testWidgets('a subtitle suggested by the server is shown from the start', (
    tester,
  ) async {
    app.playback.defaultSubtitle = 4;
    await startPlaying(tester);
    expect(app.engine.trackLog, ['audio 1', 'subtitle 1']);
    await leave(tester);
  });

  testWidgets('audio menu: Portuguese is mpv track 2, and is reported', (
    tester,
  ) async {
    await startPlaying(tester);
    await pick(tester, PlayerScreen.audioMenu, PlayerScreen.audioItem(3));
    expect(app.engine.trackLog.last, 'audio 2');
    expect(lastReport().audioStreamIndex, 3);

    // The menu now has it checked.
    await tester.tap(find.byKey(PlayerScreen.audioMenu));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckedPopupMenuItem<(int?,)>>(
            find.byKey(PlayerScreen.audioItem(3)),
          )
          .checked,
      isTrue,
    );
    await tester.tapAt(Offset.zero); // close the menu
    await tester.pumpAndSettle();
    await leave(tester);
  });

  testWidgets('subtitle menu: the external file is downloaded, then Off', (
    tester,
  ) async {
    await startPlaying(tester);
    await pick(tester, PlayerScreen.subtitleMenu, PlayerScreen.subtitleItem(0));
    expect(
      app.engine.trackLog.last,
      'add /Videos/x/x/Subtitles/0/0/Stream.subrip',
    );
    expect(app.engine.subtitleTrack.language, 'por');
    expect(lastReport().subtitleStreamIndex, 0);

    await pick(tester, PlayerScreen.subtitleMenu, PlayerScreen.subtitleOff);
    expect(app.engine.trackLog.last, 'subtitle no');
    expect(lastReport().subtitleStreamIndex, -1);
    await leave(tester);
  });

  testWidgets('A cycles audio; L cycles subtitles through Off; S toggles', (
    tester,
  ) async {
    await startPlaying(tester);
    app.engine.trackLog.clear();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    expect(app.engine.trackLog, ['audio 2', 'audio 1']);

    app.engine.trackLog.clear();
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      await tester.pump();
    }
    // Off → external por → embedded eng → Off.
    expect(app.engine.trackLog, [
      'add /Videos/x/x/Subtitles/0/0/Stream.subrip',
      'subtitle 1',
      'subtitle no',
    ]);

    // S brings back the last one shown, then hides it again.
    app.engine.trackLog.clear();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pump();
    expect(app.engine.trackLog, ['subtitle 1', 'subtitle no']);
    await leave(tester);
  });

  testWidgets('volume: arrows, mute, and the report', (tester) async {
    await startPlaying(tester);
    final engine = app.engine;

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(engine.volume, 90);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(engine.volume, 95);

    await tester.tap(find.byKey(PlayerScreen.muteButton));
    await tester.pump();
    expect(engine.muted, isTrue);
    expect(find.byTooltip('Unmute'), findsOneWidget);

    // Raising the volume unmutes.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(engine.muted, isFalse);
    expect(engine.volume, 100);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pump();
    await tester.tap(find.byKey(PlayerScreen.playPauseButton)); // a report
    await tester.pump();
    expect(lastReport().isMuted, isTrue);
    expect(lastReport().volumeLevel, 100);
    await leave(tester);
  });

  testWidgets('full screen: F11 and the button; leaving restores the window', (
    tester,
  ) async {
    await startPlaying(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f11);
    await tester.pump();
    expect(app.window.isFullScreen, isTrue);
    expect(find.byTooltip('Exit full screen'), findsOneWidget);

    await tester.tap(find.byKey(PlayerScreen.fullscreenButton));
    await tester.pump();
    expect(app.window.isFullScreen, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pump();
    expect(app.window.isFullScreen, isTrue);
    await leave(tester);
    expect(app.window.isFullScreen, isFalse);
  });

  testWidgets('transcoding: another audio track means a new stream from '
      'the same place', (tester) async {
    app.playback.method = PlayMethod.transcode;
    await startPlaying(tester);
    app.engine.advance(const Duration(seconds: 30));

    await pick(tester, PlayerScreen.audioMenu, PlayerScreen.audioItem(3));
    expect(app.playback.prepareCalls.last, (
      const Duration(seconds: 30),
      3,
      -1,
    ));
    expect(app.engine.opened, hasLength(2));
    expect(app.engine.openedStart, const Duration(seconds: 30));
    // The old stream's stop saved the position; the new one reports on.
    expect(app.playback.stopped.single.positionTicks, 30 * 10000000);
    expect(app.playback.started, hasLength(2));
    expect(app.playback.started.last.audioStreamIndex, 3);
    await leave(tester);
  });
}
