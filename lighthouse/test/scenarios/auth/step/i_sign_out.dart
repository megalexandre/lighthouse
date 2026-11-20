import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: When I sign out
///
/// The button for it in home's top bar.
Future<void> iSignOut(WidgetTester tester) async {
  await tester.tap(find.byKey(HomeScreen.signOutButton));
  await tester.pumpAndSettle();
}
