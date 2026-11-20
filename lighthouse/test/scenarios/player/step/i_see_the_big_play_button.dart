import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: And I see the big play button
///
/// In the middle of the paused video.
Future<void> iSeeTheBigPlayButton(WidgetTester tester) async {
  expect(find.byKey(PlayerScreen.centerPlayButton), findsOneWidget);
}
