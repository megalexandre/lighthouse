import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/up_next.dart';

/// Usage: And it counts down from {6} seconds
///
/// The card says how long until the next episode starts by itself.
Future<void> itCountsDownFromSeconds(WidgetTester tester, num seconds) async {
  expect(
    find.descendant(
      of: find.byKey(UpNextCard.card),
      matching: find.text('UP NEXT · IN $seconds S'),
    ),
    findsOneWidget,
  );
}
