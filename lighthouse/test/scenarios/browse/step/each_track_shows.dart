import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

import '../../../support/fakes.dart';

/// Usage: And each track shows {'3m'}
///
/// Its length, on its line of the album.
Future<void> eachTrackShows(WidgetTester tester, String text) async {
  for (final track in TestItems.tracks) {
    expect(
      find.descendant(
        of: find.byKey(ItemScreen.trackKey(track.id)),
        matching: find.text(text),
      ),
      findsOneWidget,
    );
  }
}
