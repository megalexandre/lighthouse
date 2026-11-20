import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/browse_navigation.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:lighthouse/features/player/presentation/osd/settings_menu.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// Android's Back (the button or the edge swipe) does what Esc does: it
// closes what is open on the page first, then leaves it.
void main() {
  testWidgets('leaves a page for the one before', (tester) async {
    await TestApp(theme: TestApp.prime)
        .openOnPhone(tester, Routes.item(TestItems.testMovie.id));
    expect(find.byType(ItemScreen), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(ItemScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('leaves the search page opened from the bar below', (
    tester,
  ) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    await tester.tap(find.byKey(BrowseFrame.searchItem));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(SearchScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('on a tablet on its side, closes the search field before '
      'leaving Home', (tester) async {
    usePhone(tester);
    await TestApp(theme: TestApp.prime)
        .open(tester, Routes.home, window: const Size(1280, 800));
    await tester.tap(find.byKey(FloatingTopBar.searchButton));
    await tester.pumpAndSettle();
    expect(find.byKey(FloatingTopBar.searchField), findsOneWidget);

    await systemBack(tester);
    expect(find.byKey(FloatingTopBar.searchField), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('in the player: up the menu, closes it, then leaves saving '
      'the resume point', (tester) async {
    final app = TestApp(theme: TestApp.prime);
    await app.openOnPhone(tester, Routes.play(TestItems.testMovie.id));
    await tester.tap(find.byKey(PlayerScreen.settingsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SettingsMenu.audioRow));
    await tester.pumpAndSettle();
    expect(find.byKey(SettingsMenu.audioRow), findsNothing);

    await systemBack(tester);
    expect(find.byKey(SettingsMenu.audioRow), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(SettingsMenu), findsNothing);
    expect(find.byType(PlayerScreen), findsOneWidget);
    expect(app.playback.stopped, isEmpty);

    await systemBack(tester);
    expect(find.byType(PlayerScreen), findsNothing);
    expect(app.playback.stopped, hasLength(1));
  });

  testWidgets('in the reader: closes the contents, then leaves', (
    tester,
  ) async {
    await TestApp(theme: TestApp.prime)
        .openOnPhone(tester, Routes.read(TestItems.testNovel.id));
    await tester.tap(find.byKey(ReaderScreen.contentsButton));
    await tester.pumpAndSettle();
    expect(find.byKey(ReaderScreen.contentsTab), findsOneWidget);

    await systemBack(tester);
    expect(find.byKey(ReaderScreen.contentsTab), findsNothing);
    expect(find.byType(ReaderScreen), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(ReaderScreen), findsNothing);
  });
}

/// Android's Back, as the system sends it to the app.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
