import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I double-click the video
Future<void> iDoubleclickTheVideo(WidgetTester tester) async {
  final video = tester.getCenter(find.byType(PlayerScreen));
  await tester.tapAt(video);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tapAt(video);
  await tester.pumpAndSettle();
}
