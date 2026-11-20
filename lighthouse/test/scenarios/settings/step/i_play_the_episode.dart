import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

/// Usage: When I play the episode
///
/// From its page, already open.
Future<void> iPlayTheEpisode(WidgetTester tester) async {
  await tester.tap(find.byKey(ItemScreen.playButton));
  await tester.pumpAndSettle();
}
