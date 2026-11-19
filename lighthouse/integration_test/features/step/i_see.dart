import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// Usage: Then I see {'Continue reading · 40%'}
Future<void> iSee(WidgetTester tester, String text) async {
  await waitFor(tester, find.text(text));
}
