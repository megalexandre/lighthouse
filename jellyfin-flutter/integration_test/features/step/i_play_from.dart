import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/item/presentation/item_screen.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';

import '../../support/app.dart';
import 'navigation.dart';

/// Usage: When I play {'Test Movie (2020)'} from {'Movies'}
///
/// Home → the library → the item's page → Play.
Future<void> iPlayFrom(WidgetTester tester, String name, String library) async {
  await openFromLibrary(tester, library, name);
  final play = onScreen(ItemScreen, find.byKey(ItemScreen.playButton));
  await waitFor(tester, play);
  await tapOn(tester, play);
  await waitFor(tester, find.byKey(PlayerScreen.positionText));
}
