import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/browse_navigation.dart';

/// Usage: Then the profile sheet names {'alice'}
///
/// Who is signed in, at the top of the sheet the navigation's Profile
/// opens.
Future<void> theProfileSheetNames(WidgetTester tester, String user) async {
  expect(
    find.descendant(of: find.byType(ProfileSheet), matching: find.text(user)),
    findsOneWidget,
  );
}
