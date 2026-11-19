import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: When I go back
///
/// The back button of the screen shown: to the page this one opened from.
Future<void> iGoBack(WidgetTester tester) async {
  await tapOn(tester, find.byType(BackButton).hitTestable().first);
  await settleRoute(tester);
}
