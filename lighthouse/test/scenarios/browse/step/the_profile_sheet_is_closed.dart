import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/browse_navigation.dart';

/// Usage: And the profile sheet is closed
Future<void> theProfileSheetIsClosed(WidgetTester tester) async {
  expect(find.byType(ProfileSheet), findsNothing);
}
