import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I drag the floating window
Future<void> iDragTheFloatingWindow(WidgetTester tester) async {
  final window = tester.getRect(find.byKey(PlayerScreen.floatingWindow));
  await tester.dragFrom(
    window.centerLeft.translate(8, 0),
    const Offset(60, 40),
    kind: PointerDeviceKind.mouse,
  );
  await tester.pumpAndSettle();
}
