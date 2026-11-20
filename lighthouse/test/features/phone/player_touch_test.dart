import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// The player on touch, as phone players are: a tap shows or hides the
// controls, a double tap on a half goes back or on 10 s, the volume is the
// phone's keys'.
void main() {
  Future<TestApp> play(WidgetTester tester) async {
    final app = TestApp(theme: TestApp.prime);
    await app.openOnPhone(tester, Routes.play(TestItems.testMovie.id));
    return app;
  }

  /// The controls are up: the subtitles rise above them.
  bool controlsUp(TestApp app) => app.engine.subtitleLift > 0;

  Offset at(double x) =>
      Offset(TestWindows.phone.width * x, TestWindows.phone.height / 2);

  Future<void> tapVideo(WidgetTester tester, double x) async {
    await tester.tapAt(at(x));
    // A single tap is known once no second one follows.
    await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  Future<void> doubleTapVideo(WidgetTester tester, double x) async {
    await tester.tapAt(at(x));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(at(x));
    await tester.pumpAndSettle();
  }

  testWidgets('a tap hides and shows the controls, and does not pause', (
    tester,
  ) async {
    final app = await play(tester);
    expect(controlsUp(app), isTrue);

    await tapVideo(tester, 0.5);
    expect(controlsUp(app), isFalse);
    expect(app.engine.playing, isTrue);

    await tapVideo(tester, 0.5);
    expect(controlsUp(app), isTrue);
    expect(app.engine.playing, isTrue);
  });

  testWidgets('a double tap on the right goes on 10 s, on the left back', (
    tester,
  ) async {
    final app = await play(tester);
    await app.engine.seek(const Duration(seconds: 30));

    await doubleTapVideo(tester, 0.8);
    expect(app.engine.position, const Duration(seconds: 40));

    await doubleTapVideo(tester, 0.2);
    expect(app.engine.position, const Duration(seconds: 30));
    expect(app.engine.playing, isTrue);
  });

  testWidgets('no volume button: the phone has keys for it', (tester) async {
    await play(tester);
    expect(find.byKey(PlayerScreen.muteButton), findsNothing);
    expect(find.byKey(PlayerScreen.playPauseButton), findsOneWidget);
  });

  testWidgets('the seek bar\'s preview goes when the finger lifts', (
    tester,
  ) async {
    await play(tester);
    final bar = find.byKey(PlayerScreen.seekBar);
    final preview = find.descendant(
      of: bar,
      matching: find.byType(IgnorePointer),
    );
    final gesture = await tester.startGesture(tester.getCenter(bar));
    // The first move starts the drag, the next ones show where it is.
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(preview, findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(preview, findsNothing);
  });
}
