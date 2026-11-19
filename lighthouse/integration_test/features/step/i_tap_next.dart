import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

import '../../support/app.dart';

/// Usage: When I tap Next
Future<void> iTapNext(WidgetTester tester) async {
  await waitFor(tester, find.byKey(PlayerScreen.nextButton));
  await tapOn(tester, find.byKey(PlayerScreen.nextButton));
}
