// The design system's player pieces (osd/): the seek bar's chapters and
// preview, the ±10 s buttons, the settings panel's speed and Esc, the big
// play button, and the subtitles rising with the controls. The "Up next"
// card is in up_next.feature.
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/chapter_info.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/osd/settings_menu.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/router.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  Future<void> play(WidgetTester tester, String itemId) async {
    await app.open(tester, Routes.item(itemId));
    await tester.tap(find.byKey(ItemScreen.playButton));
    await tester.pumpAndSettle();
  }

  Future<void> leave(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }

  testWidgets('seek bar: chapter names in the hover preview; a click there '
      'seeks', (tester) async {
    app.library.movies = [
      TestItems.testMovie.copyWith(
        chapters: const [
          ChapterInfo(name: 'Opening'),
          ChapterInfo(startPositionTicks: 5 * 60 * 10000000, name: 'Storm'),
        ],
      ),
    ];
    await play(tester, TestItems.testMovie.id);
    final bar = tester.getRect(find.byKey(PlayerScreen.seekBar));
    // The fake media lasts 10 minutes: 3/4 of the way is 7:30.
    final at = Offset(bar.left + bar.width * 0.75, bar.center.dy);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: at);
    await mouse.moveTo(at);
    await tester.pump();
    expect(find.text('7:30'), findsOneWidget);
    expect(find.text('Storm'), findsOneWidget);

    await tester.tapAt(at);
    await tester.pump();
    expect(app.engine.position, const Duration(minutes: 7, seconds: 30));
    await mouse.removePointer();
    await leave(tester);
  });

  testWidgets('−10 s / +10 s buttons', (tester) async {
    await play(tester, TestItems.testMovie.id);
    app.engine.advance(const Duration(seconds: 30));
    await tester.tap(find.byKey(PlayerScreen.seekForwardButton));
    await tester.pump();
    expect(app.engine.position, const Duration(seconds: 40));
    await tester.tap(find.byKey(PlayerScreen.seekBackButton));
    await tester.pump();
    expect(app.engine.position, const Duration(seconds: 30));
    await leave(tester);
  });

  testWidgets('settings panel: speed; Esc goes back a level, then closes, '
      'and only then leaves', (tester) async {
    await play(tester, TestItems.testMovie.id);
    await tester.tap(find.byKey(PlayerScreen.settingsButton));
    await tester.pumpAndSettle();
    expect(find.text('Normal'), findsOneWidget); // Speed's current value.
    await tester.tap(find.byKey(SettingsMenu.speedRow));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SettingsMenu.speedItem(1.5)));
    await tester.pumpAndSettle();
    expect(app.engine.rate, 1.5);
    expect(find.byType(SettingsMenu), findsNothing); // Choosing closes it.

    await tester.tap(find.byKey(PlayerScreen.settingsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SettingsMenu.speedRow));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(SettingsMenu.speedRow), findsOneWidget); // Back up.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsMenu), findsNothing);
    expect(find.byType(PlayerScreen), findsOneWidget); // Still playing.
    await leave(tester);
    expect(find.byType(PlayerScreen), findsNothing);
  });

  testWidgets('paused: the big play button; it plays', (tester) async {
    await play(tester, TestItems.testMovie.id);
    expect(find.byKey(PlayerScreen.centerPlayButton), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    await tester.tap(find.byKey(PlayerScreen.centerPlayButton));
    await tester.pump();
    expect(app.engine.playing, isTrue);
    expect(find.byKey(PlayerScreen.centerPlayButton), findsNothing);
    await leave(tester);
  });

  testWidgets('subtitles rise while the controls are up; a double click '
      'toggles full screen', (tester) async {
    await play(tester, TestItems.testMovie.id);
    expect(app.engine.subtitleLift, 96);
    await tester.pump(const Duration(seconds: 4)); // The controls hide.
    expect(app.engine.subtitleLift, 0);

    final video = tester.getCenter(find.byType(PlayerScreen));
    await tester.tapAt(video);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(video);
    await tester.pumpAndSettle();
    expect(app.window.isFullScreen, isTrue);
    await leave(tester);
  });
}
