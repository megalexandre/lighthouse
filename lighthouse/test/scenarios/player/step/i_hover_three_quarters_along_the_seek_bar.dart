import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart' as world;

/// Usage: And I hover three quarters along the seek bar
///
/// The fake media lasts 10 minutes: that is 7:30.
Future<void> iHoverThreeQuartersAlongTheSeekBar(WidgetTester tester) async {
  final bar = tester.getRect(find.byKey(PlayerScreen.seekBar));
  final at = world.mouseAt = Offset(bar.left + bar.width * 0.75, bar.center.dy);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: at);
  await mouse.moveTo(at);
  await tester.pump();
}
