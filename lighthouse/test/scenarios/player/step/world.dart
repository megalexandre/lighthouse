import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/playback_report.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server,
/// library, player... (see test/support/fakes.dart). Made by
/// `the app is signed in`, each scenario its own.
late TestApp app;

/// The scenario's tester, for the hooks: `Hooks.afterEach` closes the app
/// with it, and gets no tester of its own.
late WidgetTester tester;

/// Where the mouse last went, for a click there.
Offset? mouseAt;

/// A finger kept on the screen, from `I slide a finger along the seek bar`
/// to `I lift the finger`.
TestGesture? finger;

/// The keys the steps name, as the desktop client's keyboard.json does.
const keys = {
  'Esc': LogicalKeyboardKey.escape,
  'Space': LogicalKeyboardKey.space,
  'Left': LogicalKeyboardKey.arrowLeft,
  'Right': LogicalKeyboardKey.arrowRight,
  'Up': LogicalKeyboardKey.arrowUp,
  'Down': LogicalKeyboardKey.arrowDown,
  'Home': LogicalKeyboardKey.home,
  'A': LogicalKeyboardKey.keyA,
  'F': LogicalKeyboardKey.keyF,
  'L': LogicalKeyboardKey.keyL,
  'M': LogicalKeyboardKey.keyM,
  'S': LogicalKeyboardKey.keyS,
  'C': LogicalKeyboardKey.keyC,
  'I': LogicalKeyboardKey.keyI,
  'F11': LogicalKeyboardKey.f11,
  'Next track': LogicalKeyboardKey.mediaTrackNext,
};

/// The buttons the steps name: on an item's page, then in the player.
const buttons = <String, Key>{
  'play': ItemScreen.playButton,
  'resume': ItemScreen.resumeButton,
  'watched': ItemScreen.watchedButton,
  'back': PlayerScreen.backButton,
  'play/pause': PlayerScreen.playPauseButton,
  'big play': PlayerScreen.centerPlayButton,
  'mute': PlayerScreen.muteButton,
  'full screen': PlayerScreen.fullscreenButton,
  'next': PlayerScreen.nextButton,
  'previous': PlayerScreen.previousButton,
  '+10 s': PlayerScreen.seekForwardButton,
  '-10 s': PlayerScreen.seekBackButton,
  'settings': PlayerScreen.settingsButton,
  // The side panel's: "episodes" on an episode, "chapters" on a movie.
  'episodes': PlayerScreen.sidePanelButton,
  'chapters': PlayerScreen.sidePanelButton,
  'close panel': PlayerScreen.sidePanelClose,
  'panel tab': PlayerScreen.sidePanelTab,
  'resume after break': PlayerScreen.resumeAfterBreak,
  'floating window': PlayerScreen.floatingButton,
  'back to the window': PlayerScreen.floatingExpand,
  'close floating window': PlayerScreen.floatingClose,
};

/// The fake movie's tracks (FakePlaybackRepository.streams), by the
/// server's stream index.
const audioIndex = {'English': 2, 'Portuguese': 3};
const subtitleIndex = {'Portuguese': 0, 'English': 4};

/// The last thing the server was told about the playback: a progress
/// report, or the start when there was none yet.
PlaybackProgressInfo lastReport() => app.playback.progress.isEmpty
    ? app.playback.started.last
    : app.playback.progress.last;

const ticksPerSecond = 10000000;

/// Where the video is: the player, the whole window.
Rect videoArea(WidgetTester tester) =>
    tester.getRect(find.byType(PlayerScreen));

/// Where a sideways swipe of [percent] of the video's width toward [side]
/// starts (a little above the middle, clear of the big play button and of
/// the edges), and how far it goes.
(Offset, Offset) sideways(WidgetTester tester, num percent, String side) {
  final video = videoArea(tester);
  final toLeft = side == 'left';
  final start = video.topLeft.translate(
    video.width * (toLeft ? 0.75 : 0.25),
    video.height * 0.4,
  );
  final by = video.width * percent / 100;
  return (start, Offset(toLeft ? -by : by, 0));
}

/// The mouse wheel turned by [delta] over the video, beside its middle
/// (the big play button is there).
Future<void> scrollOverVideo(WidgetTester tester, Offset delta) async {
  final video = videoArea(tester);
  final mouse = TestPointer(1, PointerDeviceKind.mouse);
  final at = video.topLeft.translate(video.width * 0.25, video.height * 0.4);
  await tester.sendEventToBinding(mouse.hover(at));
  await tester.sendEventToBinding(mouse.scroll(delta));
  await tester.pumpAndSettle();
}

/// The side panel's rows, as their titles: episodes ("2. Episode 2") or
/// chapters ("Storm").
Finder panelRow(String title) => find.ancestor(
  of: find.descendant(
    of: find.byKey(PlayerScreen.sidePanel),
    matching: find.text(title),
  ),
  matching: find.byType(InkWell),
);
