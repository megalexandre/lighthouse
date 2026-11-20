import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/browse_navigation.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/features/library/presentation/libraries_screen.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';
import 'package:lighthouse/features/settings/presentation/settings_screen.dart';
import 'package:lighthouse/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

// Below the desktop's width the top bar has no room for the library tabs:
// the navigation is a bar below on a phone, a rail on a tablet or a phone
// on its side (BrowseFrame).
void main() {
  testWidgets('a phone has a bar below and only the mark above', (
    tester,
  ) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(FloatingTopBar.mark), findsOneWidget);
    expect(find.byKey(FloatingTopBar.homeTab), findsNothing);
    expect(find.byKey(FloatingTopBar.searchButton), findsNothing);
    expect(find.byKey(FloatingTopBar.profileButton), findsNothing);
  });

  testWidgets('Libraries lists them; one opens with Libraries still on', (
    tester,
  ) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    await tester.tap(find.byKey(BrowseFrame.librariesItem));
    await tester.pumpAndSettle();
    expect(find.byType(LibrariesScreen), findsOneWidget);
    for (final view in TestItems.views) {
      expect(find.byKey(ItemCard.keyFor(view.id)), findsOneWidget);
    }

    await tester.tap(find.byKey(ItemCard.keyFor(TestItems.moviesView.id)));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      BrowseTab.libraries.index,
    );
    // The library's name is the top bar's title.
    expect(
      find.descendant(
        of: find.byType(FloatingTopBar),
        matching: find.text(TestItems.moviesView.name),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(BrowseFrame.homeItem));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LibraryScreen), findsNothing);
  });

  testWidgets('Search opens the search page', (tester) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    await tester.tap(find.byKey(BrowseFrame.searchItem));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('Profile: who is signed in, Settings, Sign out', (tester) async {
    final app = TestApp(theme: TestApp.prime);
    await app.openOnPhone(tester, Routes.home);
    await tester.tap(find.byKey(BrowseFrame.profileItem));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSheet), findsOneWidget);
    expect(find.text(testSession.userName), findsOneWidget);

    await tester.tap(find.byKey(FloatingTopBar.settingsItem));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSheet), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('signing out from the profile sheet', (tester) async {
    await TestApp(theme: TestApp.prime).openOnPhone(tester, Routes.home);
    await tester.tap(find.byKey(BrowseFrame.profileItem));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FloatingTopBar.signOutItem));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('a phone on its side has a rail at the left', (tester) async {
    await TestApp(theme: TestApp.prime)
        .openOnPhone(tester, Routes.home, sideways: true);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byKey(BrowseFrame.librariesItem));
    await tester.pumpAndSettle();
    expect(find.byType(LibrariesScreen), findsOneWidget);
  });

  testWidgets('the desktop keeps the tabs in the top bar', (tester) async {
    await TestApp(theme: TestApp.prime).open(tester, Routes.home);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(FloatingTopBar.homeTab), findsOneWidget);
  });
}
