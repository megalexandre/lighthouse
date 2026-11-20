import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then I see the cover
///
/// Music has no picture: the album's cover takes its place.
Future<void> iSeeTheCover(WidgetTester tester) async {
  expect(find.byKey(PlayerScreen.cover), findsOneWidget);
}
