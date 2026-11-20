import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I drag the volume all the way down
///
/// Its slider, beside the mute button.
Future<void> iDragTheVolumeAllTheWayDown(WidgetTester tester) async {
  final slider = tester.getRect(find.byKey(PlayerScreen.volumeSlider));
  await tester.dragFrom(slider.center, Offset(-slider.width, 0));
  await tester.pumpAndSettle();
}
