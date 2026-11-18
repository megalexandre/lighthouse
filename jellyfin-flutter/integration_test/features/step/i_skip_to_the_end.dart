import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

/// Usage: And I skip to the end
///
/// Page Down jumps further than the fixtures last, so playback ends.
Future<void> iSkipToTheEnd(WidgetTester tester) async {
  await pressKey(tester, LogicalKeyboardKey.pageDown);
}
