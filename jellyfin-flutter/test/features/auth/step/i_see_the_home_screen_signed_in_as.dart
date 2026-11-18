import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/home/presentation/home_screen.dart';

/// Usage: Then I see the home screen signed in as {'alice'}
///
/// Home is open, with the user's name in the app bar.
Future<void> iSeeTheHomeScreenSignedInAs(
  WidgetTester tester,
  String username,
) async {
  expect(find.byType(HomeScreen), findsOneWidget);
  expect(find.text(username), findsOneWidget);
}
