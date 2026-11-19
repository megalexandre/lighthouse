import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/playback_report.dart';
import 'package:lighthouse/features/player/presentation/osd/player_osd.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:lighthouse/widgets/media_badge.dart';
import 'package:material_ui/material_ui.dart';

import 'support/fakes.dart';

/// Every screen fits a phone upright, a phone on its side and a tablet, as
/// it fits a desktop: nothing overflows (a test fails on an overflow).
/// Then what changes on a phone.
void main() {
  const windows = {
    'phone': TestWindows.phone,
    'phone on its side': TestWindows.phoneSideways,
    'tablet': TestWindows.tablet,
  };
  const screens = {
    'home': Routes.home,
    'library': '/library/view-movies',
    'movie': '/item/movie-1',
    'series': '/item/series-1',
    'season': '/item/season-1',
    'album': '/item/album-1',
    'book': '/item/book-comic',
    'search': '/search?q=test',
    'settings': Routes.settings,
    'player': '/play/movie-1',
    'reader': '/read/book-comic',
  };
  // Prime lays home and the libraries out its own way (floating bar,
  // carousel); the other screens look the same in both themes.
  const primeScreens = {'home', 'library'};

  for (final MapEntry(key: windowName, value: window) in windows.entries) {
    group(
      'on a $windowName (${window.width.round()}×${window.height.round()})',
      () {
        for (final MapEntry(key: name, value: route) in screens.entries) {
          testWidgets('$name fits', (tester) async {
            await TestApp().open(tester, route, window: window);
            // Past the first second: the player's controls, the reader's
            // first page.
            await tester.pump(const Duration(seconds: 1));
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          });
          if (primeScreens.contains(name)) {
            testWidgets('$name fits in Prime', (tester) async {
              await TestApp(theme: 'builtin:prime.json')
                  .open(tester, route, window: window);
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox.shrink());
            });
          }
        }
      },
    );
  }

  group('the player', () {
    double rowOf(WidgetTester tester, Key key) =>
        tester.getCenter(find.byKey(key)).dy;

    Future<TestApp> play(WidgetTester tester, Size window) async {
      // A transcode: the player shows a TRANSCODING badge.
      final app = TestApp()..playback.method = PlayMethod.transcode;
      await app.open(tester, '/play/movie-1', window: window);
      return app;
    }

    testWidgets('on a phone: the transport on a row of its own, no badges', (
      tester,
    ) async {
      await play(tester, TestWindows.phone);
      expect(
        rowOf(tester, PlayerScreen.playPauseButton),
        lessThan(rowOf(tester, PlayerScreen.fullscreenButton)),
      );
      expect(
        find.descendant(
          of: find.byType(PlayerOsd),
          matching: find.byType(MediaBadge),
        ),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('on a desktop: one row of buttons, with the badges', (
      tester,
    ) async {
      await play(tester, TestWindows.desktop);
      expect(
        rowOf(tester, PlayerScreen.playPauseButton),
        rowOf(tester, PlayerScreen.fullscreenButton),
      );
      expect(
        find.descendant(
          of: find.byType(PlayerOsd),
          matching: find.byType(MediaBadge),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('settings', () {
    /// The theme field's label and its dropdown.
    (Rect label, Rect control) themeField(WidgetTester tester) => (
      tester.getRect(find.text('Theme')),
      tester.getRect(
        find.descendant(
          of: find.byKey(SettingsScreen.themeField),
          matching: find.byType(DropdownButton<String>),
        ),
      ),
    );

    testWidgets('on a phone: each control under its label', (tester) async {
      await TestApp().open(tester, Routes.settings, window: TestWindows.phone);
      final (label, control) = themeField(tester);
      expect(control.top, greaterThanOrEqualTo(label.bottom));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('on a desktop: each control beside its label', (tester) async {
      await TestApp().open(tester, Routes.settings);
      final (label, control) = themeField(tester);
      expect(control.left, greaterThan(label.right));
      expect(control.top, lessThan(label.bottom));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
