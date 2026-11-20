import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// Every screen as on an Android phone (Prime, the only theme with a phone
// layout): upright under the status bar, on its side beside the camera's
// notch, and with the large font size many people pick.
void main() {
  final screens = {
    'home': Routes.home,
    'library': Routes.library(TestItems.moviesView.id),
    'movie': Routes.item(TestItems.testMovie.id),
    'series': Routes.item(TestItems.testShow.id),
    'season': Routes.item(TestItems.season1.id),
    'album': Routes.item(TestItems.testAlbum.id),
    'search': Routes.searchFor('test'),
    'settings': Routes.settings,
    'player': Routes.play(TestItems.testMovie.id),
    'reader': Routes.read(TestItems.testBook.id),
  };

  for (final sideways in [false, true]) {
    final how = sideways ? 'on its side' : 'upright';
    for (final MapEntry(key: name, value: location) in screens.entries) {
      testWidgets('$name, $how: clear of the system bars and notch', (
        tester,
      ) async {
        await TestApp(theme: TestApp.prime)
            .openOnPhone(tester, location, sideways: sideways);
        expectClearOfSystem(tester);
      });
    }
  }

  for (final MapEntry(key: name, value: location) in screens.entries) {
    testWidgets('$name: touch targets of at least 48 px', (tester) async {
      await TestApp(theme: TestApp.prime).openOnPhone(tester, location);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('$name: fits with a large font', (tester) async {
      await TestApp(theme: TestApp.prime)
          .openOnPhone(tester, location, textScale: 1.3);
      // An overflow is reported as an exception, which fails the test.
      expect(tester.takeException(), isNull);
    });
  }

  for (final sideways in [false, true]) {
    testWidgets('sign-in screens, ${sideways ? 'on its side' : 'upright'}', (
      tester,
    ) async {
      final app = TestApp(theme: TestApp.prime);
      usePhone(tester, sideways: sideways);
      await app.pump(tester);
      expectClearOfSystem(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  }
}

/// No text or icon is under what the system covers: the status bar, a
/// notch, the gesture bar. What scrolls may pass under the gesture bar
/// (and what is scrolled out of the window is not checked).
void expectClearOfSystem(WidgetTester tester) {
  final view = tester.view;
  final window = Offset.zero & view.physicalSize / view.devicePixelRatio;
  final padding = view.padding;
  final safe = Rect.fromLTRB(
    padding.left / view.devicePixelRatio,
    padding.top / view.devicePixelRatio,
    window.width - padding.right / view.devicePixelRatio,
    window.height - padding.bottom / view.devicePixelRatio,
  );
  final covered = <String>[];
  for (final element in find.byType(RichText).evaluate()) {
    final box = element.renderObject! as RenderBox;
    if (!box.hasSize || box.size.isEmpty) continue;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (!rect.overlaps(window)) continue;
    final scrolls = Scrollable.maybeOf(element) != null;
    final clear =
        rect.left >= safe.left - 0.5 &&
        rect.top >= safe.top - 0.5 &&
        (rect.right <= safe.right + 0.5 || rect.right > window.right) &&
        (scrolls || rect.bottom <= safe.bottom + 0.5);
    if (!clear) {
      final text = (element.widget as RichText).text.toPlainText();
      covered.add('"$text" at $rect');
    }
  }
  expect(covered, isEmpty, reason: 'safe area: $safe');
}
