import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I click the floating window
///
/// Beside its buttons; a click is told from a double click once the
/// double click's time is over.
Future<void> iClickTheFloatingWindow(WidgetTester tester) async {
  final window = tester.getRect(find.byKey(PlayerScreen.floatingWindow));
  await tester.tapAt(
    window.centerLeft.translate(8, 0),
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}
