import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/osd/up_next.dart';

/// Usage: And I tap watch now
Future<void> iTapWatchNow(WidgetTester tester) async {
  await tester.tap(find.byKey(UpNextCard.watchNowButton));
  await tester.pumpAndSettle();
}
