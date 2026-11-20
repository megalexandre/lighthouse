import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: And I do not see the libraries
Future<void> iDoNotSeeTheLibraries(WidgetTester tester) async {
  expect(find.byKey(HomeScreen.viewsRow), findsNothing);
}
