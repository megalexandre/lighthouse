import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/media_stream.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/library/presentation/item_card.dart';
import 'package:jellyfin_flutter/router.dart';
import 'package:jellyfin_flutter/widgets/error_retry.dart';
import 'package:jellyfin_flutter/widgets/media_badge.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  String title(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(ItemScreen.title)).data!;

  testWidgets('a movie: title, facts and overview', (tester) async {
    await app.open(tester, Routes.item(TestItems.testMovie.id));
    expect(title(tester), 'Test Movie');
    expect(find.text('2020 · 1h 32m · PG'), findsOneWidget);
    expect(find.text('A movie made for tests.'), findsOneWidget);
    expect(find.byKey(ItemScreen.seriesLink), findsNothing);
  });

  testWidgets('series → season → episode → back to the series', (tester) async {
    await app.open(tester, Routes.item(TestItems.testShow.id));
    expect(title(tester), 'Test Show');
    expect(find.text('Seasons'), findsOneWidget);

    await tester.tap(find.byKey(ItemCard.keyFor(TestItems.season1.id)));
    await tester.pumpAndSettle();
    expect(title(tester), 'Season 1');
    for (final e in TestItems.episodes) {
      expect(find.byKey(ItemScreen.episodeKey(e.id)), findsOneWidget);
    }
    expect(find.text('2. Episode 2'), findsOneWidget);

    final e2 = TestItems.episodes[1];
    await tester.tap(find.byKey(ItemScreen.episodeKey(e2.id)));
    await tester.pumpAndSettle();
    expect(title(tester), 'Episode 2');
    expect(find.text('S1:E2 · 45m'), findsOneWidget);

    await tester.tap(find.byKey(ItemScreen.seriesLink));
    await tester.pumpAndSettle();
    expect(title(tester), 'Test Show');
  });

  testWidgets('an album lists its tracks', (tester) async {
    await app.open(tester, Routes.item(TestItems.testAlbum.id));
    expect(title(tester), 'Test Album');
    expect(find.text('Test Artist'), findsOneWidget);
    for (final t in TestItems.tracks) {
      expect(find.byKey(ItemScreen.trackKey(t.id)), findsOneWidget);
    }
    expect(find.text('3m'), findsNWidgets(2));
  });

  testWidgets('seasons failing does not hide the series', (tester) async {
    app.library.failures['seasons'] = const ServerUnreachable(testUrl);
    await app.open(tester, Routes.item(TestItems.testShow.id));
    expect(title(tester), 'Test Show');
    expect(find.byKey(ErrorRetry.retryButton), findsOneWidget);

    app.library.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    expect(find.byKey(ItemCard.keyFor(TestItems.season1.id)), findsOneWidget);
  });

  testWidgets('an item that cannot be loaded: error and retry', (tester) async {
    app.library.failures['item'] = const ServerUnreachable(testUrl);
    await app.open(tester, Routes.item(TestItems.testMovie.id));
    expect(find.text(const ServerUnreachable(testUrl).message), findsOneWidget);

    app.library.failures.clear();
    await tester.tap(find.byKey(ErrorRetry.retryButton));
    await tester.pumpAndSettle();
    expect(title(tester), 'Test Movie');
  });

  group('technical badges', () {
    MediaStream video({int? width, String? range}) => MediaStream(
      index: 0,
      type: MediaStreamType.video,
      width: width,
      videoRangeType: range,
    );
    MediaStream audio(int channels) =>
        MediaStream(index: 1, type: MediaStreamType.audio, channels: channels);
    const subtitle = MediaStream(index: 2, type: MediaStreamType.subtitle);

    test('resolution, dynamic range, surround, subtitles', () {
      List<String> of(List<MediaStream> streams) =>
          technicalBadges(TestItems.testMovie.copyWith(mediaStreams: streams));
      expect(of([video(width: 3840, range: 'HDR10'), audio(6), subtitle]), [
        '4K',
        'HDR10',
        '5.1',
        'CC',
      ]);
      expect(of([video(width: 1920, range: 'DOVIWithHDR10'), audio(8)]), [
        '1080P',
        'Dolby Vision',
        '7.1',
      ]);
      // SD, SDR, stereo: nothing worth a badge.
      expect(of([video(width: 640, range: 'SDR'), audio(2)]), isEmpty);
      expect(of(const []), isEmpty);
    });

    testWidgets('shown under the facts', (tester) async {
      app.library.movies = [
        TestItems.testMovie.copyWith(
          mediaStreams: [video(width: 1920), audio(6), subtitle],
        ),
      ];
      await app.open(tester, Routes.item(TestItems.testMovie.id));
      expect(find.byType(MediaBadge), findsNWidgets(3));
      expect(find.text('1080P'), findsOneWidget);
      expect(find.text('5.1'), findsOneWidget);
      expect(find.text('CC'), findsOneWidget);
    });
  });
}
