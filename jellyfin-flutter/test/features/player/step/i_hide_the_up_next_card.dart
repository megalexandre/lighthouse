import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/osd/up_next.dart';

/// Usage: And I hide the up next card
Future<void> iHideTheUpNextCard(WidgetTester tester) async {
  await tester.tap(find.byKey(UpNextCard.hideButton));
  await tester.pump();
  expect(find.byKey(UpNextCard.card), findsNothing);
}
