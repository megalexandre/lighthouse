import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I double-tap the {'right'} of the video
///
/// 'left' or 'right': a fifth of the way in from that side.
Future<void> iDoubletapTheOfTheVideo(WidgetTester tester, String side) async {
  final video = tester.getRect(find.byType(PlayerScreen));
  final at = video.topLeft.translate(
    video.width * (side == 'left' ? 0.2 : 0.8),
    video.height / 2,
  );
  await tester.tapAt(at);
  await tester.pump(const Duration(milliseconds: 60));
  await tester.tapAt(at);
  await tester.pumpAndSettle();
}
