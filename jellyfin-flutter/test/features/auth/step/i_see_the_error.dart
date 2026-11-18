import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/auth/presentation/auth_form.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then I see the error {'Wrong username or password.'}
///
/// The message under the form.
Future<void> iSeeTheError(WidgetTester tester, String message) async {
  expect(tester.widget<Text>(find.byKey(FormError.errorKey)).data, message);
}
