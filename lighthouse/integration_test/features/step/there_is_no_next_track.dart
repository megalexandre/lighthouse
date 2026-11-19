import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: And there is no next track
///
/// The last of the album.
Future<void> thereIsNoNextTrack(WidgetTester tester) async {
  expect(find.byKey(PlayerScreen.nextButton), findsNothing);
}
