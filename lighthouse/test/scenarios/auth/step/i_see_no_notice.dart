import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/auth/presentation/login_screen.dart';

/// Usage: And I see no notice
Future<void> iSeeNoNotice(WidgetTester tester) async {
  expect(find.byKey(LoginScreen.notice), findsNothing);
}
