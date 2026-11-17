import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/osd/up_next.dart';

/// Usage: Then I see the up next card for {'S1:E2 · Episode 2'}
Future<void> iSeeTheUpNextCardFor(WidgetTester tester, String title) async {
  expect(
    find.descendant(
      of: find.byKey(UpNextCard.card),
      matching: find.text(title),
    ),
    findsOneWidget,
  );
}
