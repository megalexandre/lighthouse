import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';
import 'session.dart';
import 'world.dart';

/// Usage: And the session is ended on the server while the app is closed
///
/// As when the user signs out of this device from the web UI.
Future<void> theSessionIsEndedOnTheServerWhileTheAppIsClosed(
  WidgetTester tester,
) async {
  await waitFor(tester, find.byType(HomeScreen));
  await tester.pumpWidget(const SizedBox.shrink());
  await JellyfinAuthRepository(() async => probe).logout(storedSession());
}
