import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import 'world.dart';

/// Usage: When I hover over the floating window
///
/// Its buttons show while the mouse is over it.
Future<void> iHoverOverTheFloatingWindow(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  // Beside the buttons in the middle.
  final at = tester
      .getRect(find.byKey(PlayerScreen.floatingWindow))
      .centerLeft
      .translate(8, 0);
  await mouse.addPointer(location: at);
  await mouse.moveTo(at);
  mouseAt = at;
  await tester.pumpAndSettle();
}
