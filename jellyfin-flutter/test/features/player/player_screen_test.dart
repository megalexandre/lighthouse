import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/user_item_data_dto.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  final movie = TestItems.testMovie;

  Future<void> openMovie(WidgetTester tester) =>
      app.open(tester, Routes.item(movie.id));

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Lets the OSD hide timer and stream events run.
  Future<void> pumpFor(WidgetTester tester, Duration d) async {
    await tester.pump(d);
    await tester.pump();
  }

  testWidgets('Play opens the stream from the start, reports the start', (
    tester,
  ) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));

    expect(find.byType(PlayerScreen), findsOneWidget);
    expect(find.text(movie.name), findsWidgets);
    final engine = app.engine;
    expect(engine.openedUrl, FakePlaybackRepository.urlFor(movie.id));
    expect(engine.openedHeaders, contains('Authorization'));
    expect(engine.openedStart, Duration.zero);
    expect(app.playback.started.single.itemId, movie.id);
    await pumpFor(tester, const Duration(seconds: 4)); // OSD timer
  });

  testWidgets('a partly watched movie offers Resume and Start over', (
    tester,
  ) async {
    app.library.movies = [
      movie.copyWith(
        userData: const UserItemDataDto(playbackPositionTicks: 640000000),
      ),
    ];
    await openMovie(tester);
    expect(find.text('Resume from 1:04'), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(ItemScreen.resumeButton));
    expect(app.engine.openedStart, const Duration(minutes: 1, seconds: 4));
    await pumpFor(tester, const Duration(seconds: 4));
  });

  testWidgets('back saves the position and returns to the details', (
    tester,
  ) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    app.engine.advance(const Duration(seconds: 42));

    await tapAndSettle(tester, find.byKey(PlayerScreen.backButton));
    expect(find.byType(PlayerScreen), findsNothing);
    expect(find.byType(ItemScreen), findsOneWidget);
    expect(app.playback.stopped.single.positionTicks, 42 * 10000000);
    expect(app.engines.single.disposed, isTrue);
  });

  testWidgets('Esc leaves too', (tester) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsNothing);
    expect(app.playback.stopped, hasLength(1));
  });

  testWidgets('play / pause: button, space, and the report', (tester) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    final engine = app.engine;
    expect(engine.playing, isTrue);

    await tester.tap(find.byKey(PlayerScreen.playPauseButton));
    await tester.pump();
    expect(engine.playing, isFalse);
    expect(app.playback.progress.last.isPaused, isTrue);
    // The bar's button, and the big one in the middle of the paused video.
    expect(find.byTooltip('Play (Space)'), findsNWidgets(2));
    expect(find.byKey(PlayerScreen.centerPlayButton), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(engine.playing, isTrue);
    expect(app.playback.progress.last.isPaused, isFalse);
    await pumpFor(tester, const Duration(seconds: 4));
  });

  testWidgets('arrows seek 10 s, not past either end', (tester) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    final engine = app.engine;

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(engine.position, const Duration(seconds: 10));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(engine.position, Duration.zero);
    expect(
      tester.widget<Text>(find.byKey(PlayerScreen.positionText)).data,
      '0:00',
    );
    await pumpFor(tester, const Duration(seconds: 4));
  });

  testWidgets('the OSD hides while playing and stays while paused', (
    tester,
  ) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    double opacity() =>
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

    expect(opacity(), 1);
    await pumpFor(tester, const Duration(seconds: 4));
    expect(opacity(), 0);

    await app.engine.pause();
    await tester.pump();
    expect(opacity(), 1);
    await pumpFor(tester, const Duration(seconds: 4));
    expect(opacity(), 1);
  });

  testWidgets('played to the end: saved and closed', (tester) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    app.engine.finish();
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsNothing);
    expect(
      app.playback.stopped.single.positionTicks,
      const Duration(minutes: 10).inMicroseconds * 10,
    );
  });

  testWidgets('cannot play: the reason, and back', (tester) async {
    app.playback.failures['prepare'] = const NotPlayable('NotAllowed');
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.playButton));
    expect(find.text(const NotPlayable('NotAllowed').message), findsOneWidget);
    expect(app.engines, isEmpty);

    await tapAndSettle(tester, find.byKey(PlayerScreen.backButton));
    expect(find.byType(ItemScreen), findsOneWidget);
  });

  testWidgets('mark as watched, and back', (tester) async {
    await openMovie(tester);
    await tapAndSettle(tester, find.byKey(ItemScreen.watchedButton));
    expect(app.playback.played, {movie.id: true});
  });

  testWidgets('series and seasons have no Play button', (tester) async {
    await app.open(tester, Routes.item(TestItems.testShow.id));
    expect(find.byKey(ItemScreen.playButton), findsNothing);
  });
}
