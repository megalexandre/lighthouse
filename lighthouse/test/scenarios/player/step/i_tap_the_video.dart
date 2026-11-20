import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: When I tap the video
///
/// Once, in its middle. A single tap is known once no second one
/// follows, so this waits that long.
Future<void> iTapTheVideo(WidgetTester tester) async {
  await tester.tapAt(tester.getCenter(find.byType(PlayerScreen)));
  await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}
