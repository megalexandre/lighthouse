import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I drag the seek bar from a quarter to halfway
///
/// The fake media lasts 10 minutes: from 2:30 to 5:00.
Future<void> iDragTheSeekBarFromAQuarterToHalfway(WidgetTester tester) async {
  final bar = tester.getRect(find.byKey(PlayerScreen.seekBar));
  await tester.dragFrom(
    Offset(bar.left + bar.width / 4, bar.center.dy),
    Offset(bar.width / 4, 0),
  );
  await tester.pumpAndSettle();
}
