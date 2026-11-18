import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// Usage: Then I see the error {'Wrong username or password.'}
Future<void> iSeeTheError(WidgetTester tester, String message) async {
  await waitFor(tester, find.text(message));
}
