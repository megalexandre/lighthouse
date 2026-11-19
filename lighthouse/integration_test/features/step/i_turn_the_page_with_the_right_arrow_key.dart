import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// Usage: When I turn the page with the right arrow key
Future<void> iTurnThePageWithTheRightArrowKey(WidgetTester tester) async {
  await pressKey(tester, LogicalKeyboardKey.arrowRight);
  await tester.pump(const Duration(milliseconds: 500));
}
