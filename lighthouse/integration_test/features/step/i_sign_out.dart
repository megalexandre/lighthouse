import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../support/app.dart';
import 'session.dart';
import 'world.dart' as world;

/// Usage: And I sign out
///
/// From home, once the sign-in is through.
Future<void> iSignOut(WidgetTester tester) async {
  await waitFor(tester, find.byType(HomeScreen));
  world.oldSession = storedSession();
  await tester.tap(find.byKey(HomeScreen.signOutButton));
}
