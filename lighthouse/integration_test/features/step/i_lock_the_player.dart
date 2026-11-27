import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: When I lock the player
///
/// The mouse moved over the video first: the controls may have hidden.
Future<void> iLockThePlayer(WidgetTester tester) async {
  await waitFor(tester, find.byKey(PlayerScreen.lockButton));
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  final video = tester.getRect(find.byType(PlayerScreen));
  await mouse.addPointer(location: video.center);
  await mouse.moveTo(video.center.translate(10, 10));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.byKey(PlayerScreen.lockButton));
  await waitFor(tester, find.byKey(PlayerScreen.unlockButton));
}
