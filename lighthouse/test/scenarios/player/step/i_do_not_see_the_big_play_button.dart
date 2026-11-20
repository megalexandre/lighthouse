import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then I do not see the big play button
Future<void> iDoNotSeeTheBigPlayButton(WidgetTester tester) async {
  expect(find.byKey(PlayerScreen.centerPlayButton), findsNothing);
}
