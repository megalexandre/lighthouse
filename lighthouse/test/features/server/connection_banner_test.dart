import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/library/application/library_providers.dart';
import 'package:lighthouse/features/player/application/pending_reports.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:lighthouse/features/server/application/connection_controller.dart';
import 'package:lighthouse/features/server/presentation/connection_banner.dart';
import 'package:lighthouse/router.dart';

import '../../support/fakes.dart';

void main() {
  late TestApp app;

  setUp(() => app = TestApp());

  const down = ServerUnreachable(testUrl);

  /// The server goes away (as an API call would report it).
  void serverGone(WidgetTester tester) {
    for (final key in ['views', 'latest', 'resume', 'nextUp']) {
      app.library.failures[key] = down;
    }
    app.serverUp = false;
    app
        .containerOf(tester)
        .read(connectionProvider.notifier)
        .report(reachable: false);
  }

  void serverBack() {
    app.library.failures.clear();
    app.serverUp = true;
  }

  testWidgets('down: the banner; back: it goes and the screen reloads', (
    tester,
  ) async {
    await app.open(tester, Routes.home);
    expect(find.byKey(ConnectionBanner.banner), findsNothing);

    serverGone(tester);
    app.containerOf(tester).invalidate(userViewsProvider); // a reload
    await tester.pumpAndSettle();
    expect(find.byKey(ConnectionBanner.banner), findsOneWidget);
    expect(find.text("Can't reach Test Server. Trying again…"), findsOneWidget);
    expect(find.byKey(HomeScreen.viewsRow), findsNothing);

    // Still down after the first automatic try (1 s).
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(ConnectionBanner.banner), findsOneWidget);

    // Back: the next try (2 s later) finds it; home loads by itself.
    serverBack();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(ConnectionBanner.banner), findsNothing);
    expect(find.byKey(HomeScreen.viewsRow), findsOneWidget);
  });

  testWidgets('Retry now does not wait for the timer', (tester) async {
    await app.open(tester, Routes.home);
    serverGone(tester);
    await tester.pumpAndSettle();
    serverBack();
    await tester.tap(find.byKey(ConnectionBanner.retryButton));
    await tester.pumpAndSettle();
    expect(find.byKey(ConnectionBanner.banner), findsNothing);
  });

  testWidgets('playback broke off: not watched, the place kept, Resume', (
    tester,
  ) async {
    await app.open(tester, Routes.item(TestItems.testMovie.id));
    await tester.tap(find.byKey(ItemScreen.playButton));
    await tester.pumpAndSettle();
    app.engine.advance(const Duration(seconds: 30));

    app.engine.breakOff();
    await tester.pumpAndSettle();
    expect(find.byType(PlayerScreen), findsOneWidget, reason: 'stays open');
    expect(find.text('Resume from 0:30'), findsOneWidget);
    expect(app.playback.stopped.single.positionTicks, 30 * 10000000);

    await tester.tap(find.byKey(PlayerScreen.resumeAfterBreak));
    await tester.pumpAndSettle();
    expect(app.playback.prepareCalls.last.$1, const Duration(seconds: 30));
    expect(app.engine.openedStart, const Duration(seconds: 30));
    expect(find.byKey(PlayerScreen.resumeAfterBreak), findsNothing);
    expect(app.playback.started, hasLength(2));
  });

  testWidgets('a stop report the server never got is sent when it is back', (
    tester,
  ) async {
    await app.open(tester, Routes.item(TestItems.testMovie.id));
    await tester.tap(find.byKey(ItemScreen.playButton));
    await tester.pumpAndSettle();
    app.engine.advance(const Duration(seconds: 42));

    app.playback.stopFailure = down;
    await tester.tap(find.byKey(PlayerScreen.backButton));
    await tester.pumpAndSettle();
    final c = app.containerOf(tester);
    expect(c.read(pendingReportsProvider), hasLength(1));
    expect(app.playback.stopped, isEmpty);

    app.playback.stopFailure = null;
    c.read(connectionProvider.notifier)
      ..report(reachable: false)
      ..report(reachable: true);
    await tester.pumpAndSettle();
    expect(app.playback.stopped.single.positionTicks, 42 * 10000000);
    expect(c.read(pendingReportsProvider), isEmpty);
  });
}
