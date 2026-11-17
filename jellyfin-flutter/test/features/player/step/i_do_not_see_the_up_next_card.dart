import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/osd/up_next.dart';

/// Usage: Then I do not see the up next card
Future<void> iDoNotSeeTheUpNextCard(WidgetTester tester) async {
  expect(find.byKey(UpNextCard.card), findsNothing);
}
